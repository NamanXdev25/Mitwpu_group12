import Foundation

struct HydrationHistoryModel {

    // MARK: - Storage
    private static let historyKey = "hydration_daily_history"

    enum Period {
        case weekly
        case monthly
    }

    // MARK: - Public API

    static func addWater(amount: Double) {
        var history = loadHistory()
        let todayKey = dateKey(for: Date())
        history[todayKey, default: 0] += amount
        saveHistory(history)
    }

    static func average(for period: Period) -> Double {
        let values = chartValues(for: period)
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    static func chartValues(for period: Period) -> [Double] {
        let history = loadHistory()
        let today = Date()

        switch period {

        // MARK: - Weekly (Sunday → Saturday)
        case .weekly:
            var calendar = Calendar.current
            calendar.firstWeekday = 1 // Sunday

            let startOfWeek = calendar.date(
                from: calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: today
                )
            )!

            // Always return exactly 7 values (Sun → Sat)
            return (0..<7).map { offset in
                let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
                return history[dateKey(for: date)] ?? 0
            }

        // MARK: - Monthly
        case .monthly:
            let calendar = Calendar.current

            guard let range = calendar.range(of: .day, in: .month, for: today) else {
                return []
            }

            return range.map { day in
                var comps = calendar.dateComponents([.year, .month], from: today)
                comps.day = day
                let date = calendar.date(from: comps)!
                return history[dateKey(for: date)] ?? 0
            }
        }
    }

    // MARK: - Persistence

    private static func loadHistory() -> [String: Double] {
        UserDefaults.standard.dictionary(forKey: historyKey) as? [String: Double] ?? [:]
    }

    private static func saveHistory(_ history: [String: Double]) {
        UserDefaults.standard.set(history, forKey: historyKey)
    }

    private static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
