// swiftlint:disable file_length
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
        local: AppointmentRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local ?? UserDefaultsAppointmentRepository(key: "SavedAppointments_\(userId.uuidString)")
        self.userId = userId
        self.client = client
    }

    func loadAppointments() -> [String: [AppointmentItem]] {
        return local.loadAppointments()
    }

    func saveAppointments(_ appointments: [String: [AppointmentItem]]) {
        local.saveAppointments(appointments)
        SyncManager.shared.markDirty(.appointments)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        client.fetchRows(from: "appointments", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [AppointmentSupabaseRow]) in
            guard !rows.isEmpty else { completion(); return }
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
                completion()
            }
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        let appointments = local.loadAppointments()

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
        return local.loadHistory()
    }

    func saveHistory(_ history: [String: MedicationHistoryEntry]) {
        local.saveHistory(history)
        SyncManager.shared.markDirty(.medicationHistory)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        client.fetchRows(from: "medication_history_snapshots", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [MedicationHistorySnapshotSupabaseRow]) in
            guard !rows.isEmpty else { completion(); return }

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
            completion()
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        let history = local.loadHistory()

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
        local: MemoryRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local ?? UserDefaultsMemoryRepository(key: "saved_memories_\(userId.uuidString)")
        self.userId = userId
        self.client = client
    }

    func loadMemories() -> [Memory] {
        return local.loadMemories()
    }

    func saveMemories(_ memories: [Memory]) {
        local.saveMemories(memories)
        SyncManager.shared.markDirty(.memories)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        client.fetchRows(from: "memories", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [MemorySupabaseRow]) in
            guard !rows.isEmpty else { completion(); return }
            self.local.saveMemories(rows.map(Memory.init(supabaseRow:)).sorted { $0.date > $1.date })
            completion()
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        let memories = local.loadMemories()

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
        local: HydrationRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local ?? UserDefaultsHydrationRepository(key: "hydrationEntries_\(userId.uuidString)")
        self.userId = userId
        self.client = client
    }

    func loadEntries() -> [HydrationEntry] {
        return local.loadEntries()
    }

    func saveEntries(_ entries: [HydrationEntry]) {
        local.saveEntries(entries)
        SyncManager.shared.markDirty(.hydration)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        client.fetchRows(from: "hydration_daily_status", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [HydrationDailySupabaseRow]) in
            guard !rows.isEmpty else { completion(); return }
            let dailyEntries = rows
                .filter { $0.consumed_ml > 0 }
                .map(HydrationEntry.init(supabaseDailyRow:))
                .sorted { $0.timestamp > $1.timestamp }
            self.local.saveEntries(dailyEntries)
            completion()
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        let entries = local.loadEntries()

        let calendar = Calendar.current
        let groupedByDate = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }

        client.fetchRows(from: "hydration_daily_status", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (existingRows: [HydrationDailySupabaseRow]) in
            let storedGoalML = UserDefaults.standard.integer(forKey: self.hydrationGoalKey)
            let currentGoalML = storedGoalML > 0 ? storedGoalML : self.defaultGoalML
            let existingGoalByDateKey = Dictionary(uniqueKeysWithValues: existingRows.map { ($0.date_key, $0.goal_ml) })
            let todayKey = DateFormatter.supabaseDateKey.string(from: calendar.startOfDay(for: Date()))

            var rowsToUpsert = groupedByDate.map { dayStart, dayEntries in
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

            let localDateKeys = Set(rowsToUpsert.map(\.date_key))
            for existingRow in existingRows where !localDateKeys.contains(existingRow.date_key) {
                rowsToUpsert.append(
                    HydrationDailySupabaseRow(
                        id: existingRow.id,
                        user_id: self.userId,
                        date_key: existingRow.date_key,
                        date_epoch: existingRow.date_epoch,
                        consumed_ml: 0,
                        goal_ml: existingRow.goal_ml,
                        updated_at: Date()
                    )
                )
            }

            self.client.upsertRows(
                rowsToUpsert,
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
            SyncManager.shared.markDirty(.symptoms)
        }
        return cleaned
    }

    func saveLogs(_ logs: [SymptomLog]) {
        let cleaned = removeLegacySeedLogsIfNeeded(from: logs)
        local.saveLogs(cleaned)
        SyncManager.shared.markDirty(.symptoms)
    }

    func loadUserSymptomIDs() -> [String] {
        return local.loadUserSymptomIDs()
    }

    func saveUserSymptomIDs(_ ids: [String]) {
        local.saveUserSymptomIDs(ids)
        SyncManager.shared.markDirty(.symptoms)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        let group = DispatchGroup()

        group.enter()
        client.fetchRows(from: "symptom_logs", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [SymptomLogSupabaseRow]) in
            guard !rows.isEmpty else { group.leave(); return }
            let orderedLogs = rows.map(SymptomLog.init(supabaseRow:)).sorted { $0.timestamp > $1.timestamp }
            let cleanedLogs = self.removeLegacySeedLogsIfNeeded(from: orderedLogs)
            self.local.saveLogs(cleanedLogs)

            if cleanedLogs.count != orderedLogs.count {
                SyncManager.shared.markDirty(.symptoms)
            }
            group.leave()
        }

        group.enter()
        client.fetchRows(from: "symptom_user_preferences", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [SymptomPreferenceSupabaseRow]) in
            guard !rows.isEmpty else { group.leave(); return }
            self.local.saveUserSymptomIDs(rows.first?.user_symptom_ids ?? [])
            group.leave()
        }

        group.notify(queue: .global(qos: .utility)) { completion() }
    }

    func pushToCloud() {
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
        local: JournalRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local ?? UserDefaultsJournalRepository(key: "journal_entries_v1_\(userId.uuidString)")
        self.userId = userId
        self.client = client
    }

    func loadEntries() -> [JournalEntry] {
        return local.loadEntries()
    }

    func saveEntries(_ entries: [JournalEntry]) {
        local.saveEntries(entries)
        SyncManager.shared.markDirty(.journal)
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

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
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
                SyncManager.shared.markDirty(.journal)
            } else {
                self.local.saveEntries(orderedEntries)
            }
            completion()
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        let entries = local.loadEntries()
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
                updated_at: orderedTimestamp
            )
        }

        let currentIDs = Set(rows.map(\.id))
        client.upsertRows(rows, into: "journals") { success in
            guard success else { return }
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
        local: BreathingRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local ?? UserDefaultsBreathingRepository(key: "breathing_favorites_v1_\(userId.uuidString)")
        self.userId = userId
        self.client = client
    }

    func loadFavoriteTitles() -> [String] {
        return local.loadFavoriteTitles()
    }

    func saveFavoriteTitles(_ titles: [String]) {
        local.saveFavoriteTitles(titles)
        SyncManager.shared.markDirty(.breathing)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        client.fetchRows(from: "breathing_favorites", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [BreathingFavoriteSupabaseRow]) in
            guard !rows.isEmpty else { completion(); return }
            let orderedTitles = rows
                .sorted { ($0.created_at ?? .distantPast) > ($1.created_at ?? .distantPast) }
                .map(\.title)
            self.local.saveFavoriteTitles(orderedTitles)
            completion()
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        let titles = local.loadFavoriteTitles()

        let now = Date()
        let rows = titles.enumerated().map {
            BreathingFavoriteSupabaseRow(
                id: UUID(),
                user_id: userId,
                title: $0.element,
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
        return local.loadProfile()
    }

    func saveProfile(_ profile: ProfileUserProfile) {
        local.saveProfile(profile)
        SyncManager.shared.markDirty(.profile)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        client.fetchRows(
            from: "user_profiles",
            filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]
        ) { (rows: [UserProfileSupabaseRow]) in
            if let row = rows.first {
                self.local.saveProfile(ProfileUserProfile(supabaseRow: row))
            } else if let localProfile = self.local.loadProfile() {
                // No cloud data yet — push local profile up
                SyncManager.shared.markDirty(.profile)
            }
            completion()
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        guard let profile = local.loadProfile() else { return }
        client.upsertRows([profile.toSupabaseRow(userId: userId)], into: "user_profiles", onConflict: "user_id")
    }
}

final class SupabaseExerciseRepository: ExerciseRepository {
    private let local: ExerciseRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: ExerciseRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local ?? UserDefaultsExerciseRepository(completionsKey: "uas_exerciseCompletions_\(userId.uuidString)")
        self.userId = userId
        self.client = client
    }

    func loadCompletions() -> [String: [ExerciseCompletionRecord]] {
        return local.loadCompletions()
    }

    func saveCompletions(_ completions: [String: [ExerciseCompletionRecord]]) {
        local.saveCompletions(completions)
        SyncManager.shared.markDirty(.exercise)
    }

    func loadSelectedPlanID() -> Int? {
        return local.loadSelectedPlanID()
    }

    func saveSelectedPlanID(_ id: Int?) {
        local.saveSelectedPlanID(id)
        SyncManager.shared.markDirty(.exercise)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        let group = DispatchGroup()

        group.enter()
        client.fetchRows(from: "exercise_completions", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [ExerciseCompletionSupabaseRow]) in
            guard !rows.isEmpty else { group.leave(); return }
            var map: [String: [ExerciseCompletionRecord]] = [:]
            for row in rows {
                let record = ExerciseCompletionRecord(supabaseRow: row)
                map[row.date_key, default: []].append(record)
            }
            for key in map.keys {
                map[key]?.sort { $0.completedAt > $1.completedAt }
            }
            self.local.saveCompletions(map)
            group.leave()
        }

        group.enter()
        client.fetchRows(from: "exercise_selected_plans", filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]) { (rows: [ExerciseSelectedPlanSupabaseRow]) in
            if let row = rows.first {
                self.local.saveSelectedPlanID(row.plan_id)
            }
            group.leave()
        }

        group.notify(queue: .global(qos: .utility)) { completion() }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }

        // Push completions
        let completions = local.loadCompletions()
        let rows = completions.flatMap { dateKey, records in
            records.compactMap { $0.toSupabaseRow(userId: userId, dateKey: dateKey) }
        }
        if !rows.isEmpty {
            client.upsertRows(rows, into: "exercise_completions")
        }

        // Push selected plan
        if let id = local.loadSelectedPlanID(), id > 0 {
            let row = ExerciseSelectedPlanSupabaseRow(
                user_id: userId,
                plan_id: id,
                updated_at: Date()
            )
            client.upsertRows([row], into: "exercise_selected_plans", onConflict: "user_id")
        } else {
            client.deleteAllRows(forUser: userId, from: "exercise_selected_plans")
        }
    }
}

final class SupabaseJourneyRepository: JourneyRepository {
    private let local: JourneyRepository
    private let userId: UUID
    private let client: SupabaseRESTClient

    init(
        local: JourneyRepository? = nil,
        userId: UUID = SupabaseUserContext.userId,
        client: SupabaseRESTClient = .shared
    ) {
        self.local = local ?? UserDefaultsJourneyRepository(key: "js_journey_snapshot_\(userId.uuidString)", isIsolated: true)
        self.userId = userId
        self.client = client
    }

    func loadState() -> PersistedJourneySnapshot? {
        return local.loadState()
    }

    func saveState(_ state: PersistedJourneySnapshot) {
        local.saveState(state)
        SyncManager.shared.markDirty(.journey)
    }

    // MARK: - SyncManager hooks

    func pullFromCloud(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        var journeyRow: JourneyStateSupabaseRow?
        var phaseRows: [TreatmentPhaseSupabaseRow] = []

        let filter = [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]

        dispatchGroup.enter()
        client.fetchRows(from: "journey_state", filters: filter) { (rows: [JourneyStateSupabaseRow]) in
            journeyRow = rows.first
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        client.fetchRows(from: "treatment_phases", filters: filter) { (rows: [TreatmentPhaseSupabaseRow]) in
            phaseRows = rows
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self, let row = journeyRow else { completion(); return }
            let sortedPhases = phaseRows.sorted {
                let id1 = Int($0.id.components(separatedBy: "#").last ?? "0") ?? 0
                let id2 = Int($1.id.components(separatedBy: "#").last ?? "0") ?? 0
                return id1 < id2
            }
            let snapshot = PersistedJourneySnapshot(journeyRow: row, phaseRows: sortedPhases)
            self.local.saveState(snapshot)
            completion()
        }
    }

    func pushToCloud() {
        guard client.isConfigured else { return }
        guard let state = local.loadState() else { return }

        let journeyRow = state.toJourneySupabaseRow(userId: userId)
        let phaseRows = state.toTreatmentPhaseRows(userId: userId)

        // 1. Upsert parent row
        client.upsertRows([journeyRow], into: "journey_state", onConflict: "user_id")

        // 2. Clear old children then upsert new ones
        let filters = [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]
        client.deleteRows(from: "treatment_phases", filters: filters) { [weak self] _ in
            guard let self else { return }
            // 3. Upsert new children
            if !phaseRows.isEmpty {
                self.client.upsertRows(phaseRows, into: "treatment_phases", onConflict: "id")
            }
        }
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
