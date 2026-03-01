import Foundation

// Data manager for hydration entries
class HydrationDataManager {
    static let shared = HydrationDataManager()

    private(set) var entries: [HydrationEntry] = []
    private let userDefaultsKey = "hydrationEntries"

    private init() {
        loadEntries()
    }

    // MARK: - CRUD Operations

    func addEntry(_ entry: HydrationEntry) {
        entries.append(entry)
        entries.sort { $0.timestamp > $1.timestamp }
        saveEntries()
    }

    func updateEntry(withId id: UUID, newAmount: Int) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index] = HydrationEntry(id: id, amountML: newAmount, timestamp: entries[index].timestamp)
            saveEntries()
        }
    }

    func deleteEntry(withId id: UUID) {
        entries.removeAll { $0.id == id }
        saveEntries()
    }

    func getTotalForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        return entries.filter {
            calendar.isDate($0.timestamp, inSameDayAs: date)
        }.reduce(0) { $0 + $1.amountML }
    }

    // MARK: - Persistence

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([HydrationEntry].self, from: data) {
            entries = decoded.sorted { $0.timestamp > $1.timestamp }
        } else {
            entries = [
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-25200)),
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-19500)),
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-14400)),
                HydrationEntry(amountML: 500, timestamp: Date().addingTimeInterval(-3600)),
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-1800))
            ]
        }
    }
}
