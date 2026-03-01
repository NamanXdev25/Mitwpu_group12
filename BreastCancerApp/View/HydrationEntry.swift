import Foundation

class HydrationDataManager {
    static let shared = HydrationDataManager()

    private let repository: HydrationRepository
    private(set) var entries: [HydrationEntry] = []

    init(repository: HydrationRepository = UserDefaultsHydrationRepository()) {
        self.repository = repository
        self.entries = repository.loadEntries()

        if entries.isEmpty {
            entries = [
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-25200)),
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-19500)),
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-14400)),
                HydrationEntry(amountML: 500, timestamp: Date().addingTimeInterval(-3600)),
                HydrationEntry(amountML: 250, timestamp: Date().addingTimeInterval(-1800))
            ]
            persist()
        }
    }

    private func persist() {
        repository.saveEntries(entries)
    }

    func addEntry(_ entry: HydrationEntry) {
        entries.append(entry)
        entries.sort { $0.timestamp > $1.timestamp }
        persist()
    }

    func updateEntry(withId id: UUID, newAmount: Int) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index] = HydrationEntry(id: id, amountML: newAmount, timestamp: entries[index].timestamp)
            persist()
        }
    }

    func deleteEntry(withId id: UUID) {
        entries.removeAll { $0.id == id }
        persist()
    }

    func getTotalForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            .reduce(0) { $0 + $1.amountML }
    }
}
