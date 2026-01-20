import Foundation

struct HydrationHistoryModel {

    private static let historyKey = "hydration_daily_history"
    private static let defaults = UserDefaults.standard

    enum Period {
        case weekly
        case monthly
    }

    static func addWaterML(_ ml: Int) {
        var history = loadHistory()
        let todayKey = dateKey(for: Date())
        history[todayKey, default: 0] += Double(ml)
        saveHistory(history)
    }

    static func average(for period: Period) -> Double {
        let valuesML = chartValuesML(for: period)
        guard !valuesML.isEmpty else { return 0 }
        let avgML = valuesML.reduce(0, +) / Double(valuesML.count)
        return avgML / 1000.0
    }

    static func chartValues(for period: Period) -> [Double] {
        chartValuesML(for: period).map { $0 / 1000.0 }
    }

    private static func chartValuesML(for period: Period) -> [Double] {
        let history = loadHistory()
        let today = Date()
        let calendar = Calendar.current

        switch period {
        case .weekly:
            var calendar = calendar
            calendar.firstWeekday = 1

            guard let startOfWeek = calendar.date(
                from: calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: today
                )
            ) else {
                return []
            }

            return (0..<7).map { offset in
                let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
                return history[dateKey(for: date)] ?? 0
            }

        case .monthly:
            guard let range = calendar.range(of: .day, in: .month, for: today) else {
                return []
            }

            return range.map { day in
                var components = calendar.dateComponents([.year, .month], from: today)
                components.day = day
                let date = calendar.date(from: components)!
                return history[dateKey(for: date)] ?? 0
            }
        }
    }

    private static func loadHistory() -> [String: Double] {
        defaults.dictionary(forKey: historyKey) as? [String: Double] ?? [:]
    }

    private static func saveHistory(_ history: [String: Double]) {
        defaults.set(history, forKey: historyKey)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func dateKey(for date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
