import Foundation

private extension SupabaseRESTClient {
    func deleteAllRows(forUser userId: UUID, from table: String, completion: ((Bool) -> Void)? = nil) {
        deleteRows(from: table, filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)], completion: completion)
    }
}

final class SupabaseAppointmentRepository: AppointmentRepository {
    private let local: AppointmentRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: AppointmentRepository = UserDefaultsAppointmentRepository(),
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local
        self.userId = userId
        self.client = client
    }

    func loadAppointments() -> [String: [AppointmentItem]] {
        let cached = local.loadAppointments()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveAppointments(_ appointments: [String: [AppointmentItem]]) {
        local.saveAppointments(appointments)
        syncSnapshotToCloud(appointments)
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(from: "appointments", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [AppointmentSupabaseRow]) in
            guard !rows.isEmpty else { return }
            self.client.fetchRows(from: "appointment_reminders", filters: [SupabaseFilter(key: "user_id", op: "eq", value: self.userId.uuidString)]) { (reminderRows: [AppointmentReminderSupabaseRow]) in
                let reminderMap = Dictionary(grouping: reminderRows, by: \.appointment_id)
                let calendar = Calendar.current

                var map: [String: [AppointmentItem]] = [:]
                for row in rows {
                    let offsets = (reminderMap[row.id] ?? []).compactMap { ReminderOffset(minutesBefore: $0.offset_minutes) }
                    guard let item = AppointmentItem(supabaseRow: row, reminderOffsets: offsets.sorted(by: { $0.minutesBefore > $1.minutesBefore })) else {
                        continue
                    }

                    let dateKey = DateFormatter.supabaseDateKey.string(from: calendar.startOfDay(for: row.appointment_at))
                    map[dateKey, default: []].append(item)
                }

                self.local.saveAppointments(map)
            }
        }
    }

    private func syncSnapshotToCloud(_ appointments: [String: [AppointmentItem]]) {
        guard client.isConfigured else { return }

        let flattenedAppointments = appointments.values.flatMap { $0 }
        let appointmentById = Dictionary(uniqueKeysWithValues: flattenedAppointments.map { ($0.id, $0) })

        let rows = flattenedAppointments
            .compactMap { $0.toSupabaseRow(userId: userId) }

        let reminderRows = rows.flatMap { row in
            appointmentById[row.id.uuidString]?
                .reminderOffsets
                .map {
                    AppointmentReminderSupabaseRow(
                        id: UUID(),
                        user_id: userId,
                        appointment_id: row.id,
                        offset_minutes: $0.minutesBefore,
                        created_at: nil
                    )
                } ?? []
        }

        client.deleteAllRows(forUser: userId, from: "appointment_reminders") { _ in
            self.client.deleteAllRows(forUser: self.userId, from: "appointments") { _ in
                self.client.upsertRows(rows, into: "appointments")
                self.client.upsertRows(reminderRows, into: "appointment_reminders")
            }
        }
    }
}

final class SupabaseMedicationHistoryRepository: MedicationHistoryRepository {
    // Transitional snapshot sync to preserve the current offline-first medication feature set.
    // This keeps the app working while the medication module is moved toward the normalized
    // `medications` + `medication_logs` schema.
    private let local: MedicationHistoryRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: MedicationHistoryRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        let resolvedLocal = local
            ?? UserDefaultsMedicationHistoryRepository(
                key: "MedicationHistoryStore_\(userId.uuidString)",
                legacyKey: "MedicationHistoryStore"
            )
            as MedicationHistoryRepository
        self.local = resolvedLocal
        self.userId = userId
        self.client = client
    }

    func loadHistory() -> [String: MedicationHistoryEntry] {
        let cached = local.loadHistory()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveHistory(_ history: [String: MedicationHistoryEntry]) {
        local.saveHistory(history)
        syncSnapshotToCloud(history)
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(from: "medication_history_snapshots", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [MedicationHistorySnapshotSupabaseRow]) in
            // Guard: never overwrite local data when cloud returns nothing.
            // This prevents wiping medication history when the token is expired,
            // RLS blocks the read, or the cloud table is empty after a migration.
            guard !rows.isEmpty else { return }

            let groupedByDate = Dictionary(grouping: rows, by: \.date_key)

            var canonicalRows: [MedicationHistorySnapshotSupabaseRow] = []
            var staleRowIDs: [String] = []

            for (_, groupedRows) in groupedByDate {
                let sortedRows = groupedRows.sorted { lhs, rhs in
                    let lhsTimestamp = lhs.updated_at ?? Date(timeIntervalSince1970: lhs.date_epoch)
                    let rhsTimestamp = rhs.updated_at ?? Date(timeIntervalSince1970: rhs.date_epoch)
                    return lhsTimestamp > rhsTimestamp
                }

                guard let canonical = sortedRows.first else { continue }
                canonicalRows.append(canonical)
                staleRowIDs.append(contentsOf: sortedRows.dropFirst().map(\.id))
            }

            let map = canonicalRows.reduce(into: [String: MedicationHistoryEntry]()) { partialResult, row in
                partialResult[row.date_key] = MedicationHistoryEntry(supabaseRow: row)
            }
            self.local.saveHistory(map)

            for staleRowID in staleRowIDs {
                self.client.deleteRows(
                    from: "medication_history_snapshots",
                    filters: [
                        SupabaseFilter(key: "user_id", op: "eq", value: self.userId.uuidString),
                        SupabaseFilter(key: "id", op: "eq", value: staleRowID)
                    ]
                )
            }
        }
    }

    private func syncSnapshotToCloud(_ history: [String: MedicationHistoryEntry]) {
        guard client.isConfigured else { return }

        let rows = history.map { dateKey, entry in
            entry.toSupabaseRow(userId: userId, dateKey: dateKey)
        }
        let itemRows = history.flatMap { dateKey, entry in
            entry.medications.map { $0.toSupabaseItemRow(userId: userId, dateKey: dateKey) }
        }
        let latestPlanSource = history.values
            .sorted(by: { $0.date > $1.date })
            .first(where: { !$0.medications.isEmpty })
        let planRows = latestPlanSource?.medications.map { $0.toSupabasePlanRow(userId: userId) } ?? []
        let dailyStatusRows = history.flatMap { dateKey, entry in
            entry.toSupabaseDailyStatusRows(userId: userId, dateKey: dateKey)
        }

        // Do not hard-delete all medication rows before upsert.
        // Hard deletes can drop historical data from other devices that have not
        // yet pulled the latest local snapshot.
        client.upsertRows(rows, into: "medication_history_snapshots", onConflict: "user_id,date_key")
        client.upsertRows(itemRows, into: "medication_items", onConflict: "id")
        client.upsertRows(planRows, into: "medication_plans", onConflict: "id")
        client.upsertRows(dailyStatusRows, into: "medication_daily_status", onConflict: "id")
    }
}

final class SupabaseMemoryRepository: MemoryRepository {
    private let local: MemoryRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: MemoryRepository = UserDefaultsMemoryRepository(),
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local
        self.userId = userId
        self.client = client
    }

    func loadMemories() -> [Memory] {
        let cached = local.loadMemories()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveMemories(_ memories: [Memory]) {
        local.saveMemories(memories)
        syncSnapshotToCloud(memories)
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(from: "memories", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [MemorySupabaseRow]) in
            guard !rows.isEmpty else { return }
            self.local.saveMemories(rows.map(Memory.init(supabaseRow:)).sorted { $0.date > $1.date })
        }
    }

    private func syncSnapshotToCloud(_ memories: [Memory]) {
        guard client.isConfigured else { return }

        let rows = memories.map { $0.toSupabaseRow(userId: userId) }
        client.deleteAllRows(forUser: userId, from: "memories") { _ in
            self.client.upsertRows(rows, into: "memories")
        }
    }
}

final class SupabaseHydrationRepository: HydrationRepository {
    private let local: HydrationRepository
    private let userId: UUID
    private let client: SupabaseRESTClient
    private let defaultGoalML = 3000
    private let hydrationGoalKey = "care_hydration_goal_ml"

    init(
        local: HydrationRepository = UserDefaultsHydrationRepository(),
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local
        self.userId = userId
        self.client = client
    }

    func loadEntries() -> [HydrationEntry] {
        let cached = local.loadEntries()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveEntries(_ entries: [HydrationEntry]) {
        local.saveEntries(entries)
        syncSnapshotToCloud(entries)
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(from: "hydration_daily_status", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [HydrationDailySupabaseRow]) in
            guard !rows.isEmpty else { return }
            let dailyEntries = rows
                .map(HydrationEntry.init(supabaseDailyRow:))
                .sorted { $0.timestamp > $1.timestamp }
            self.local.saveEntries(dailyEntries)
        }
    }

    private func syncSnapshotToCloud(_ entries: [HydrationEntry]) {
        guard client.isConfigured else { return }

        let calendar = Calendar.current
        let groupedByDate = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }

        client.fetchRows(from: "hydration_daily_status", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (existingRows: [HydrationDailySupabaseRow]) in
            let storedGoalML = UserDefaults.standard.integer(forKey: self.hydrationGoalKey)
            let currentGoalML = storedGoalML > 0 ? storedGoalML : self.defaultGoalML
            let existingGoalByDateKey = Dictionary(uniqueKeysWithValues: existingRows.map { ($0.date_key, $0.goal_ml) })
            let todayKey = DateFormatter.supabaseDateKey.string(from: calendar.startOfDay(for: Date()))

            let rows = groupedByDate.map { dayStart, dayEntries in
                let dateKey = DateFormatter.supabaseDateKey.string(from: dayStart)
                let consumedML = dayEntries.reduce(0) { $0 + $1.amountML }
                let goalML: Int
                if dateKey == todayKey {
                    goalML = currentGoalML
                } else {
                    goalML = existingGoalByDateKey[dateKey] ?? currentGoalML
                }
                return HydrationDailySupabaseRow(
                    id: "\(self.userId.uuidString)#\(dateKey)",
                    user_id: self.userId,
                    date_key: dateKey,
                    date_epoch: dayStart.timeIntervalSince1970,
                    consumed_ml: consumedML,
                    goal_ml: goalML,
                    updated_at: Date()
                )
            }

            // Do not delete all user rows here.
            // Multiple devices can have partially synced local snapshots; a full delete from one
            // device would wipe hydration history uploaded by another device.
            // Merge by per-day key instead.
            self.client.upsertRows(
                rows,
                into: "hydration_daily_status",
                onConflict: "user_id,date_key"
            )
        }
    }
}

final class SupabaseSymptomRepository: SymptomRepository {
    private let local: SymptomRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: SymptomRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        let resolvedLocal = local
            ?? UserDefaultsSymptomRepository(
                logsKey: "symptom_logs_v1_\(userId.uuidString)",
                idsKey: "symptom_user_ids_v1_\(userId.uuidString)"
            )
            as SymptomRepository
        self.local = resolvedLocal
        self.userId = userId
        self.client = client
    }

    func loadLogs() -> [SymptomLog] {
        let cached = local.loadLogs()
        let cleaned = removeLegacySeedLogsIfNeeded(from: cached)
        if cleaned.count != cached.count {
            local.saveLogs(cleaned)
            if client.isConfigured {
                uploadCurrentState()
            }
        }
        syncFromCloudIntoLocal()
        return cleaned
    }

    func saveLogs(_ logs: [SymptomLog]) {
        let cleaned = removeLegacySeedLogsIfNeeded(from: logs)
        local.saveLogs(cleaned)
        uploadCurrentState()
    }

    func loadUserSymptomIDs() -> [String] {
        let cached = local.loadUserSymptomIDs()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveUserSymptomIDs(_ ids: [String]) {
        local.saveUserSymptomIDs(ids)
        uploadCurrentState()
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(from: "symptom_logs", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [SymptomLogSupabaseRow]) in
            guard !rows.isEmpty else { return }
            let orderedLogs = rows.map(SymptomLog.init(supabaseRow:)).sorted { $0.timestamp > $1.timestamp }
            let cleanedLogs = self.removeLegacySeedLogsIfNeeded(from: orderedLogs)
            self.local.saveLogs(cleanedLogs)

            if cleanedLogs.count != orderedLogs.count {
                self.uploadCurrentState()
            }
        }

        client.fetchRows(from: "symptom_user_preferences", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [SymptomPreferenceSupabaseRow]) in
            guard !rows.isEmpty else { return }
            self.local.saveUserSymptomIDs(rows.first?.user_symptom_ids ?? [])
        }
    }

    private func uploadCurrentState() {
        guard client.isConfigured else { return }

        let logRows = local.loadLogs().map { $0.toSupabaseRow(userId: userId) }
        let preferenceRow = SymptomPreferenceSupabaseRow(
            id: userId,
            user_id: userId,
            user_symptom_ids: local.loadUserSymptomIDs(),
            updated_at: Date()
        )

        client.deleteAllRows(forUser: userId, from: "symptom_logs") { _ in
            self.client.upsertRows(logRows, into: "symptom_logs")
        }

        // Keep exactly one preference row for the current user and always replace it
        // with the latest selected symptom IDs.
        client.deleteAllRows(forUser: userId, from: "symptom_user_preferences") { _ in
            self.client.upsertRows([preferenceRow], into: "symptom_user_preferences")
        }
    }

    private func removeLegacySeedLogsIfNeeded(from logs: [SymptomLog]) -> [SymptomLog] {
        guard !logs.isEmpty else { return logs }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        struct SeedSignature: Hashable {
            let symptomId: String
            let severity: Int
            let dayOffset: Int
        }

        let legacySeedSignatures: Set<SeedSignature> = [
            SeedSignature(symptomId: "nausea", severity: 1, dayOffset: 1),
            SeedSignature(symptomId: "pain", severity: 3, dayOffset: 1),
            SeedSignature(symptomId: "fatigue", severity: 3, dayOffset: 3),
            SeedSignature(symptomId: "headache", severity: 2, dayOffset: 3),
            SeedSignature(symptomId: "nausea", severity: 4, dayOffset: 5),
            SeedSignature(symptomId: "pain", severity: 2, dayOffset: 7),
            SeedSignature(symptomId: "fatigue", severity: 4, dayOffset: 7),
            SeedSignature(symptomId: "insomnia", severity: 3, dayOffset: 10),
            SeedSignature(symptomId: "nausea", severity: 2, dayOffset: 12),
            SeedSignature(symptomId: "appetite_loss", severity: 3, dayOffset: 12),
            SeedSignature(symptomId: "fatigue", severity: 3, dayOffset: 14),
            SeedSignature(symptomId: "pain", severity: 4, dayOffset: 14),
            SeedSignature(symptomId: "headache", severity: 1, dayOffset: 17),
            SeedSignature(symptomId: "nausea", severity: 3, dayOffset: 19),
            SeedSignature(symptomId: "fatigue", severity: 4, dayOffset: 21),
            SeedSignature(symptomId: "insomnia", severity: 2, dayOffset: 21),
            SeedSignature(symptomId: "pain", severity: 3, dayOffset: 24),
            SeedSignature(symptomId: "nausea", severity: 2, dayOffset: 26),
            SeedSignature(symptomId: "appetite_loss", severity: 4, dayOffset: 26),
            SeedSignature(symptomId: "fatigue", severity: 2, dayOffset: 28),
            SeedSignature(symptomId: "headache", severity: 3, dayOffset: 30),
            SeedSignature(symptomId: "pain", severity: 2, dayOffset: 30)
        ]

        var removalIndices = Set<Int>()

        for (index, log) in logs.enumerated() {
            let trimmedNote = log.note.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedNote.isEmpty else { continue }

            let logDay = calendar.startOfDay(for: log.timestamp)
            let dayOffset = calendar.dateComponents([.day], from: logDay, to: today).day ?? 0
            guard dayOffset >= 1 else { continue }

            let signature = SeedSignature(
                symptomId: log.symptomId.lowercased(),
                severity: log.severity,
                dayOffset: dayOffset
            )
            if legacySeedSignatures.contains(signature) {
                removalIndices.insert(index)
            }
        }

        guard removalIndices.count >= 8 else { return logs }

        return logs.enumerated().compactMap { index, log in
            removalIndices.contains(index) ? nil : log
        }
    }
}

final class SupabaseJournalRepository: JournalRepository {
    private let local: JournalRepository
    private let userId: UUID
    private let client: SupabaseRESTClient
    private let syncStateQueue = DispatchQueue(label: "BreastCancerApp.SupabaseJournalRepository.syncState")
    private var latestSyncGeneration: Int = 0

    init(
        local: JournalRepository = UserDefaultsJournalRepository(),
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local
        self.userId = userId
        self.client = client
    }

    func loadEntries() -> [JournalEntry] {
        let cached = local.loadEntries()
        if cached.isEmpty {
            syncFromCloudIntoLocal()
        } else {
            syncSnapshotToCloud(cached)
        }
        return cached
    }

    func saveEntries(_ entries: [JournalEntry]) {
        local.saveEntries(entries)
        syncSnapshotToCloud(entries)
    }

    private func beginSyncGeneration() -> Int {
        syncStateQueue.sync {
            latestSyncGeneration += 1
            return latestSyncGeneration
        }
    }

    private func isCurrentSyncGeneration(_ generation: Int) -> Bool {
        syncStateQueue.sync { latestSyncGeneration == generation }
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(from: "journals", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [JournalSupabaseRow]) in
            let orderedEntries = rows
                .sorted {
                    let lhsTimestamp = $0.updated_at ?? $0.created_at ?? $0.journal_date
                    let rhsTimestamp = $1.updated_at ?? $1.created_at ?? $1.journal_date
                    if lhsTimestamp == rhsTimestamp {
                        return $0.journal_date > $1.journal_date
                    }
                    return lhsTimestamp > rhsTimestamp
                }
                .map(JournalEntry.init(supabaseRow:))

            let localEntries = self.local.loadEntries()
            let localIDs = Set(localEntries.map(\.id))
            let cloudIDs = Set(orderedEntries.map(\.id))

            if !localEntries.isEmpty && localIDs != cloudIDs {
                let mergedEntries = localEntries + orderedEntries.filter { !localIDs.contains($0.id) }
                self.local.saveEntries(mergedEntries)
                self.syncSnapshotToCloud(mergedEntries)
                return
            }

            self.local.saveEntries(orderedEntries)
        }
    }

    private func syncSnapshotToCloud(_ entries: [JournalEntry]) {
        guard client.isConfigured else { return }
        let generation = beginSyncGeneration()

        guard !entries.isEmpty else {
            guard isCurrentSyncGeneration(generation) else { return }
            client.deleteAllRows(forUser: userId, from: "journals")
            return
        }

        let now = Date()
        let rows = entries.enumerated().map { index, entry in
            let orderedTimestamp = now.addingTimeInterval(-Double(index))
            return JournalSupabaseRow(
                id: entry.id,
                user_id: userId,
                title: entry.title,
                body: entry.body,
                type: entry.type.rawValue,
                question: entry.question,
                category: entry.category,
                journal_date: entry.date,
                created_at: orderedTimestamp,
                // Preserve the current visible list order across reloads.
                updated_at: orderedTimestamp
            )
        }

        let currentIDs = Set(rows.map(\.id))
        client.upsertRows(rows, into: "journals") { success in
            guard success else {
                print("Supabase journals upsert failed for \(rows.count) rows")
                return
            }
            guard self.isCurrentSyncGeneration(generation) else { return }

            self.client.fetchRows(
                from: "journals",
                filters: [SupabaseFilter(key: "user_id", op: "eq", value: self.userId.uuidString)]
            ) { (existingRows: [JournalSupabaseRow]) in
                guard self.isCurrentSyncGeneration(generation) else { return }
                let staleIDs = existingRows
                    .map(\.id)
                    .filter { !currentIDs.contains($0) }

                for staleID in staleIDs {
                    guard self.isCurrentSyncGeneration(generation) else { return }
                    self.client.deleteRows(
                        from: "journals",
                        filters: [
                            SupabaseFilter(key: "user_id", op: "eq", value: self.userId.uuidString),
                            SupabaseFilter(key: "id", op: "eq", value: staleID.uuidString)
                        ]
                    )
                }
            }
        }
    }
}

final class SupabaseBreathingRepository: BreathingRepository {
    private let local: BreathingRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: BreathingRepository = UserDefaultsBreathingRepository(),
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local
        self.userId = userId
        self.client = client
    }

    func loadFavoriteTitles() -> [String] {
        let cached = local.loadFavoriteTitles()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveFavoriteTitles(_ titles: [String]) {
        local.saveFavoriteTitles(titles)
        syncSnapshotToCloud(titles)
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(from: "breathing_favorites", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [BreathingFavoriteSupabaseRow]) in
            guard !rows.isEmpty else { return }
            let orderedTitles = rows
                .sorted { ($0.created_at ?? .distantPast) > ($1.created_at ?? .distantPast) }
                .map(\.title)
            self.local.saveFavoriteTitles(orderedTitles)
        }
    }

    private func syncSnapshotToCloud(_ titles: [String]) {
        guard client.isConfigured else { return }

        let now = Date()
        let rows = titles.enumerated().map {
            BreathingFavoriteSupabaseRow(
                id: UUID(),
                user_id: userId,
                title: $0.element,
                // Preserve the current visible order using an existing column.
                created_at: now.addingTimeInterval(-Double($0.offset))
            )
        }

        client.deleteAllRows(forUser: userId, from: "breathing_favorites") { _ in
            self.client.upsertRows(rows, into: "breathing_favorites")
        }
    }
}

final class SupabaseProfileRepository: ProfileRepository {
    private let local: ProfileRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: ProfileRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.userId = userId
        self.client = client
        self.local = local ?? UserDefaultsProfileRepository(key: "savedUserProfile_\(userId.uuidString)")
    }

    func loadProfile() -> ProfileUserProfile? {
        let cached = local.loadProfile()
        syncFromCloudIntoLocal()
        return cached
    }

    func saveProfile(_ profile: ProfileUserProfile) {
        local.saveProfile(profile)
        syncSnapshotToCloud(profile)
    }

    private func syncFromCloudIntoLocal() {
        client.fetchRows(
            from: "user_profiles",
            filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]
        ) { (rows: [UserProfileSupabaseRow]) in
            if let row = rows.first {
                self.local.saveProfile(ProfileUserProfile(supabaseRow: row))
                return
            }

            if let localProfile = self.local.loadProfile() {
                self.syncSnapshotToCloud(localProfile)
            }
        }
    }

    private func syncSnapshotToCloud(_ profile: ProfileUserProfile) {
        guard client.isConfigured else { return }
        client.upsertRows([profile.toSupabaseRow(userId: userId)], into: "user_profiles", onConflict: "user_id")
    }
}

private extension DateFormatter {
    static let supabaseDateKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
