import Foundation

protocol AppointmentRepository {
    func loadAppointments() -> [String: [AppointmentItem]]
    func saveAppointments(_ appointments: [String: [AppointmentItem]])
}

protocol MedicationHistoryRepository {
    func loadHistory() -> [String: MedicationHistoryEntry]
    func saveHistory(_ history: [String: MedicationHistoryEntry])
}

protocol MemoryRepository {
    func loadMemories() -> [Memory]
    func saveMemories(_ memories: [Memory])
}

protocol HydrationRepository {
    func loadEntries() -> [HydrationEntry]
    func saveEntries(_ entries: [HydrationEntry])
}

protocol SymptomRepository {
    func loadLogs() -> [SymptomLog]
    func saveLogs(_ logs: [SymptomLog])
    func loadUserSymptomIDs() -> [String]
    func saveUserSymptomIDs(_ ids: [String])
}

protocol JournalRepository {
    func loadEntries() -> [JournalEntry]
    func saveEntries(_ entries: [JournalEntry])
}

protocol BreathingRepository {
    func loadFavoriteTitles() -> [String]
    func saveFavoriteTitles(_ titles: [String])
}
