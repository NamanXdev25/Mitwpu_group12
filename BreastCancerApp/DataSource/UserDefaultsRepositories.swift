//
//  UserDefaultsRepositories.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

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
            let decoded = try? JSONDecoder().decode([String: [AppointmentFirestoreDTO]].self, from: data)
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

    init(userDefaults: UserDefaults = .standard, key: String = "MedicationHistoryStore") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadHistory() -> [String: MedicationHistoryEntry] {
        guard
            let data = userDefaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([String: MedicationHistoryEntryFirestoreDTO].self, from: data)
        else {
            return [:]
        }

        return decoded.mapValues { MedicationHistoryEntry(dto: $0) }
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
            let decoded = try? JSONDecoder().decode([MemoryFirestoreDTO].self, from: data)
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
            let decoded = try? JSONDecoder().decode([HydrationEntryFirestoreDTO].self, from: data)
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
            let decoded = try? JSONDecoder().decode([SymptomLogFirestoreDTO].self, from: data)
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
            let decoded = try? JSONDecoder().decode([JournalEntryFirestoreDTO].self, from: data)
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
