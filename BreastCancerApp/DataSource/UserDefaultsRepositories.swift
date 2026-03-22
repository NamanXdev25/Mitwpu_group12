
import Foundation

final class UserDefaultsAppointmentRepository: AppointmentRepository {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "SavedAppointments") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadAppointments() -> [String: [AppointmentItem]] {
        guard
            let data = userDefaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([String: [AppointmentDTO]].self, from: data)
        else {
            return [:]
        }

        return decoded.mapValues { $0.map(AppointmentItem.init(dto:)) }
    }

    func saveAppointments(_ appointments: [String: [AppointmentItem]]) {
        let dtoMap = appointments.mapValues { $0.map { $0.toDTO() } }
        guard let encoded = try? JSONEncoder().encode(dtoMap) else { return }
        userDefaults.set(encoded, forKey: key)
    }
}

final class UserDefaultsMedicationHistoryRepository: MedicationHistoryRepository {
    private let userDefaults: UserDefaults
    private let key: String
    private let legacyKey: String?

    init(
        userDefaults: UserDefaults = .standard,
        key: String = "MedicationHistoryStore",
        legacyKey: String? = nil
    ) {
        self.userDefaults = userDefaults
        self.key = key
        if let legacyKey {
            self.legacyKey = legacyKey
        } else if key != "MedicationHistoryStore" {
            self.legacyKey = "MedicationHistoryStore"
        } else {
            self.legacyKey = nil
        }
    }

    func loadHistory() -> [String: MedicationHistoryEntry] {
        if let data = userDefaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: MedicationHistoryEntryDTO].self, from: data) {
            return decoded.mapValues { MedicationHistoryEntry(dto: $0) }
        }

        guard let legacyKey,
              let data = userDefaults.data(forKey: legacyKey),
              let decoded = try? JSONDecoder().decode([String: MedicationHistoryEntryDTO].self, from: data) else {
            return [:]
        }

        let migrated = decoded.mapValues { MedicationHistoryEntry(dto: $0) }
        if !migrated.isEmpty {
            saveHistory(migrated)
        }
        return migrated
    }

    func saveHistory(_ history: [String: MedicationHistoryEntry]) {
        let dtoMap = history.mapValues { $0.toDTO() }
        guard let encoded = try? JSONEncoder().encode(dtoMap) else { return }
        userDefaults.set(encoded, forKey: key)
    }
}

final class UserDefaultsMemoryRepository: MemoryRepository {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "saved_memories") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadMemories() -> [Memory] {
        guard
            let data = userDefaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([MemoryDTO].self, from: data)
        else {
            return []
        }

        return decoded.map(Memory.init(dto:))
    }

    func saveMemories(_ memories: [Memory]) {
        let dto = memories.map { $0.toDTO() }
        guard let encoded = try? JSONEncoder().encode(dto) else { return }
        userDefaults.set(encoded, forKey: key)
    }
}

final class UserDefaultsHydrationRepository: HydrationRepository {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "hydrationEntries") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadEntries() -> [HydrationEntry] {
        guard
            let data = userDefaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([HydrationEntryDTO].self, from: data)
        else {
            return []
        }

        return decoded.map(HydrationEntry.init(dto:)).sorted { $0.timestamp > $1.timestamp }
    }

    func saveEntries(_ entries: [HydrationEntry]) {
        let dto = entries.map { $0.toDTO() }
        guard let encoded = try? JSONEncoder().encode(dto) else { return }
        userDefaults.set(encoded, forKey: key)
    }
}

final class UserDefaultsSymptomRepository: SymptomRepository {
    private let userDefaults: UserDefaults
    private let logsKey: String
    private let idsKey: String

    init(
        userDefaults: UserDefaults = .standard,
        logsKey: String = "symptom_logs_v1",
        idsKey: String = "symptom_user_ids_v1"
    ) {
        self.userDefaults = userDefaults
        self.logsKey = logsKey
        self.idsKey = idsKey
    }

    func loadLogs() -> [SymptomLog] {
        guard
            let data = userDefaults.data(forKey: logsKey),
            let decoded = try? JSONDecoder().decode([SymptomLogDTO].self, from: data)
        else {
            return []
        }
        return decoded.map(SymptomLog.init(dto:))
    }

    func saveLogs(_ logs: [SymptomLog]) {
        let dto = logs.map { $0.toDTO() }
        guard let data = try? JSONEncoder().encode(dto) else { return }
        userDefaults.set(data, forKey: logsKey)
    }

    func loadUserSymptomIDs() -> [String] {
        userDefaults.stringArray(forKey: idsKey) ?? []
    }

    func saveUserSymptomIDs(_ ids: [String]) {
        userDefaults.set(ids, forKey: idsKey)
    }
}

final class UserDefaultsJournalRepository: JournalRepository {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "journal_entries_v1") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadEntries() -> [JournalEntry] {
        guard
            let data = userDefaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([JournalEntryDTO].self, from: data)
        else {
            return []
        }
        return decoded.map(JournalEntry.init(dto:))
    }

    func saveEntries(_ entries: [JournalEntry]) {
        let dto = entries.map { $0.toDTO() }
        guard let encoded = try? JSONEncoder().encode(dto) else { return }
        userDefaults.set(encoded, forKey: key)
    }
}

final class UserDefaultsBreathingRepository: BreathingRepository {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "breathing_favorites_v1") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadFavoriteTitles() -> [String] {
        userDefaults.stringArray(forKey: key) ?? []
    }

    func saveFavoriteTitles(_ titles: [String]) {
        userDefaults.set(titles, forKey: key)
    }
}

final class UserDefaultsProfileRepository: ProfileRepository {
    private let userDefaults: UserDefaults
    private let key: String
    private let legacyKey: String?

    init(
        userDefaults: UserDefaults = .standard,
        key: String = "savedUserProfile",
        legacyKey: String? = nil
    ) {
        self.userDefaults = userDefaults
        self.key = key
        if let legacyKey {
            self.legacyKey = legacyKey
        } else if key != "savedUserProfile" {
            self.legacyKey = "savedUserProfile"
        } else {
            self.legacyKey = nil
        }
    }

    func loadProfile() -> ProfileUserProfile? {
        if let data = userDefaults.data(forKey: key),
           let profile = try? JSONDecoder().decode(ProfileUserProfile.self, from: data) {
            return profile
        }

        guard let legacyKey,
              let data = userDefaults.data(forKey: legacyKey) else {
            return nil
        }
        return try? JSONDecoder().decode(ProfileUserProfile.self, from: data)
    }

    func saveProfile(_ profile: ProfileUserProfile) {
        guard let encoded = try? JSONEncoder().encode(profile) else { return }
        userDefaults.set(encoded, forKey: key)
    }
}

final class UserDefaultsExerciseRepository: ExerciseRepository {
    private let userDefaults: UserDefaults
    private let completionsKey: String
    private let planIDKey: String

    init(
        userDefaults: UserDefaults = .standard,
        completionsKey: String = "uas_exerciseCompletions",
        planIDKey: String? = nil
    ) {
        self.userDefaults = userDefaults
        self.completionsKey = completionsKey
        let userKey = SupabaseUserContext.currentUserId?.uuidString ?? "anonymous"
        self.planIDKey = planIDKey ?? "care_selected_exercise_category_id_v2_\(userKey)"
    }

    func loadCompletions() -> [String: [ExerciseCompletionRecord]] {
        guard let data = userDefaults.data(forKey: completionsKey),
              let decoded = try? JSONDecoder().decode([String: [ExerciseCompletionRecord]].self, from: data) else {
            return [:]
        }
        return decoded
    }

    func saveCompletions(_ completions: [String: [ExerciseCompletionRecord]]) {
        guard let encoded = try? JSONEncoder().encode(completions) else { return }
        userDefaults.set(encoded, forKey: completionsKey)
    }

    func loadSelectedPlanID() -> Int? {
        let raw = userDefaults.object(forKey: planIDKey) as? Int
        guard let raw, raw > 0 else { return nil }
        return raw
    }

    func saveSelectedPlanID(_ id: Int?) {
        if let id, id > 0 {
            userDefaults.set(id, forKey: planIDKey)
        } else {
            userDefaults.removeObject(forKey: planIDKey)
        }
    }
}

final class UserDefaultsJourneyRepository: JourneyRepository {
    private let userDefaults: UserDefaults
    private let key: String

    private let kDiagnosisCompleted  = "js_diagnosisCompleted"
    private let kWaitCompleted       = "js_waitCompleted"
    private let kTreatmentCompleted  = "js_treatmentCompleted"
    private let kStepTitle           = "js_stepTitle"
    private let kTreatmentName       = "js_treatmentName"
    private let kPhaseStates         = "js_phaseStates"
    private let kTreatmentBadge      = "js_treatmentBadge"
    private let kPostTreatment       = "js_postTreatment"

    init(userDefaults: UserDefaults = .standard, key: String = "js_journey_snapshot") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadState() -> PersistedJourneySnapshot? {
        let d = userDefaults

        // Try new single-key format first
        if let data = d.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PersistedJourneySnapshot.self, from: data) {
            return decoded
        }

        // Fall back to legacy per-key format
        guard d.object(forKey: kDiagnosisCompleted) != nil else { return nil }

        var phaseStates: [PersistedPhaseState] = []
        if let data = d.data(forKey: kPhaseStates),
           let decoded = try? JSONDecoder().decode([PersistedPhaseState].self, from: data) {
            phaseStates = decoded
        }

        var postTreatment = PersistedPostTreatmentState(selectedDate: nil, selectedSymptoms: [], isSaved: false)
        if let data = d.data(forKey: kPostTreatment),
           let decoded = try? JSONDecoder().decode(PersistedPostTreatmentState.self, from: data) {
            postTreatment = decoded
        }

        return PersistedJourneySnapshot(
            isDiagnosisCompleted:  d.bool(forKey: kDiagnosisCompleted),
            isWaitCompleted:      d.bool(forKey: kWaitCompleted),
            isTreatmentCompleted: d.bool(forKey: kTreatmentCompleted),
            currentStepTitle:     d.string(forKey: kStepTitle) ?? "Diagnosed",
            currentTreatmentName: d.string(forKey: kTreatmentName) ?? "Not started yet",
            persistedTreatmentBadge: d.string(forKey: kTreatmentBadge) ?? "notStarted",
            phaseStates:          phaseStates,
            postTreatment:        postTreatment,
            diagnosisDate:        nil,
            waitDaysInput:        nil,
            waitSymptoms:         []
        )
    }

    func saveState(_ state: PersistedJourneySnapshot) {
        // Save in new single-key format
        if let data = try? JSONEncoder().encode(state) {
            userDefaults.set(data, forKey: key)
        }

        // Also write legacy keys so existing code continues to work
        let d = userDefaults
        d.set(state.isDiagnosisCompleted,      forKey: kDiagnosisCompleted)
        d.set(state.isWaitCompleted,            forKey: kWaitCompleted)
        d.set(state.isTreatmentCompleted,       forKey: kTreatmentCompleted)
        d.set(state.currentStepTitle,           forKey: kStepTitle)
        d.set(state.currentTreatmentName,       forKey: kTreatmentName)
        d.set(state.persistedTreatmentBadge,    forKey: kTreatmentBadge)
        if let data = try? JSONEncoder().encode(state.phaseStates) {
            d.set(data, forKey: kPhaseStates)
        }
        if let data = try? JSONEncoder().encode(state.postTreatment) {
            d.set(data, forKey: kPostTreatment)
        }
    }
}

