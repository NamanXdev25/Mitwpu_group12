import Foundation

class HydrationDataManager {
    static let shared = HydrationDataManager()

    private let repository: HydrationRepository
    private(set) var entries: [HydrationEntry] = []

    init(repository: HydrationRepository = RepositoryFactory.makeHydrationRepository()) {
        self.repository = repository
        self.entries = repository.loadEntries()
        let normalized = normalizedDailyEntries(from: entries)
        if !hasSameContent(lhs: normalized, rhs: entries) {
            entries = normalized
            persist()
        }
    }

    private func persist() {
        repository.saveEntries(entries)
    }

    func addEntry(_ entry: HydrationEntry) {
        applyDelta(entry.amountML, for: entry.timestamp)
        entries.sort { $0.timestamp > $1.timestamp }
        persist()
    }

    func adjustToday(by deltaML: Int) {
        guard deltaML != 0 else { return }
        applyDelta(deltaML, for: Date())
        entries = entries.sorted { $0.timestamp > $1.timestamp }
        persist()
    }

    func setTotalForToday(_ totalML: Int) {
        setTotal(totalML, for: Date())
    }

    func updateEntry(withId id: UUID, newAmount: Int) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            if newAmount <= 0 {
                entries.remove(at: index)
            } else {
                entries[index] = HydrationEntry(id: id, amountML: newAmount, timestamp: entries[index].timestamp)
            }
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

    private func applyDelta(_ deltaML: Int, for date: Date) {
        guard deltaML != 0 else { return }

        let calendar = Calendar.current
        if let index = entries.firstIndex(where: { calendar.isDate($0.timestamp, inSameDayAs: date) }) {
            let updatedAmount = max(0, entries[index].amountML + deltaML)
            if updatedAmount == 0 {
                entries.remove(at: index)
            } else {
                entries[index] = HydrationEntry(
                    id: entries[index].id,
                    amountML: updatedAmount,
                    timestamp: entries[index].timestamp
                )
            }
            return
        }

        guard deltaML > 0 else { return }
        entries.append(HydrationEntry(amountML: deltaML, timestamp: date))
    }

    private func setTotal(_ totalML: Int, for date: Date) {
        let targetAmount = max(0, totalML)
        let calendar = Calendar.current

        if let index = entries.firstIndex(where: { calendar.isDate($0.timestamp, inSameDayAs: date) }) {
            if targetAmount == 0 {
                entries.remove(at: index)
            } else {
                entries[index] = HydrationEntry(
                    id: entries[index].id,
                    amountML: targetAmount,
                    timestamp: date
                )
            }
        } else if targetAmount > 0 {
            entries.append(HydrationEntry(amountML: targetAmount, timestamp: date))
        }

        entries = entries.sorted { $0.timestamp > $1.timestamp }
        persist()
    }

    private func normalizedDailyEntries(from source: [HydrationEntry]) -> [HydrationEntry] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: source) { calendar.startOfDay(for: $0.timestamp) }

        return grouped.map { _, dayEntries in
            let totalAmount = dayEntries.reduce(0) { $0 + $1.amountML }
            let latestTimestamp = dayEntries.map(\.timestamp).max() ?? Date()
            let stableId = dayEntries.sorted(by: { $0.timestamp > $1.timestamp }).first?.id ?? UUID()
            return HydrationEntry(id: stableId, amountML: totalAmount, timestamp: latestTimestamp)
        }
        .sorted { $0.timestamp > $1.timestamp }
    }

    private func hasSameContent(lhs: [HydrationEntry], rhs: [HydrationEntry]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).allSatisfy {
            $0.id == $1.id &&
            $0.amountML == $1.amountML &&
            $0.timestamp == $1.timestamp
        }
    }
}
