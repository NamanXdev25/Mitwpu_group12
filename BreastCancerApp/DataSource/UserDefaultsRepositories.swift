
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
