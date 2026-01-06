import Foundation

struct HydrationHistoryModel {

    private static let historyKey = "hydration_daily_history"

    enum Period {
        case weekly
        case monthly
    }

    static func addWater(amount: Double) {
        var history = loadHistory()
        let todayKey = dateKey(for: Date())
        history[todayKey, default: 0] += amount
        saveHistory(history)
    }

    static func average(for period: Period) -> Double {
        let values = valuesFor(period: period)
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    static func chartValues(for period: Period) -> [Double] {
        valuesFor(period: period)
    }

    // MARK: - Helpers

    private static func valuesFor(period: Period) -> [Double] {
        let history = loadHistory()
        let calendar = Calendar.current
        let today = Date()

        switch period {

        case .weekly:
            return (0..<7).compactMap {
                calendar.date(byAdding: .day, value: -$0, to: today)
                    .flatMap { history[dateKey(for: $0)] }
            }.reversed()

        case .monthly:
            guard let range = calendar.range(of: .day, in: .month, for: today) else {
                return []
            }

            return range.compactMap { day in
                var comps = calendar.dateComponents([.year, .month], from: today)
                comps.day = day
                return calendar.date(from: comps)
                    .flatMap { history[dateKey(for: $0)] }
            }
        }
    }

    private static func loadHistory() -> [String: Double] {
        UserDefaults.standard.dictionary(forKey: historyKey) as? [String: Double] ?? [:]
    }

    private static func saveHistory(_ history: [String: Double]) {
        UserDefaults.standard.set(history, forKey: historyKey)
    }

    private static func dateKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
