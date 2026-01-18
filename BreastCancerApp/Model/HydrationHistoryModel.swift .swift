import Foundation

struct HydrationHistoryModel {

    // MARK: - Storage
    private static let historyKey = "hydration_daily_history"   // stored in mL

    enum Period {
        case weekly
        case monthly
    }

    // MARK: - Public API

    /// ✅ Add water in **milliliters**
    static func addWaterML(_ ml: Int) {
        var history = loadHistory()
        let todayKey = dateKey(for: Date())
        history[todayKey, default: 0] += Double(ml)
        saveHistory(history)
    }

    /// Average in liters (for charts)
    static func average(for period: Period) -> Double {
        let valuesML = chartValuesML(for: period)
        guard !valuesML.isEmpty else { return 0 }
        let avgML = valuesML.reduce(0, +) / Double(valuesML.count)
        return avgML / 1000.0
    }

    /// Chart values in liters
    static func chartValues(for period: Period) -> [Double] {
        chartValuesML(for: period).map { $0 / 1000.0 }
    }

    // MARK: - Internal (mL)

    private static func chartValuesML(for period: Period) -> [Double] {
        let history = loadHistory()
        let today = Date()

        switch period {

        case .weekly:
            var calendar = Calendar.current
            calendar.firstWeekday = 1 // Sunday

            let startOfWeek = calendar.date(
                from: calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: today
                )
            )!

            return (0..<7).map { offset in
                let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
                return history[dateKey(for: date)] ?? 0
            }

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
