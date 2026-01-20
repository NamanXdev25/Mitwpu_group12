import Foundation

struct HydrationModel {

    private static let consumedKey = "hydration_consumed"
    private static let goalKey = "hydration_goal"
    private static let cupSizeKey = "hydration_cup_size"
    private static let lastUpdatedDateKey = "hydration_last_date"

    static let defaultGoal: Double = 3.0
    static let defaultCupSize: Double = 0.2

    private static let defaults = UserDefaults.standard

    static func currentGoal() -> Double {
        let value = defaults.double(forKey: goalKey)
        return value == 0 ? defaultGoal : value
    }

    static func currentCupSize() -> Double {
        let value = defaults.double(forKey: cupSizeKey)
        return value == 0 ? defaultCupSize : value
    }

    static func consumedTodayML() -> Int {
        checkForDailyReset()
        return defaults.integer(forKey: consumedKey)
    }

    static func consumedToday() -> Double {
        Double(consumedTodayML()) / 1000.0
    }

    static func setGoal(_ goal: Double) {
        defaults.set(goal, forKey: goalKey)
    }

    static func setCupSize(_ cupSize: Double) {
        defaults.set(cupSize, forKey: cupSizeKey)
    }

    static func addWaterML(_ ml: Int) {
        checkForDailyReset()
        let current = defaults.integer(forKey: consumedKey)
        defaults.set(current + ml, forKey: consumedKey)
    }

    static func resetConsumed() {
        defaults.set(0, forKey: consumedKey)
    }

    private static func checkForDailyReset() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = defaults.object(forKey: lastUpdatedDateKey) as? Date {
            guard calendar.isDate(lastDate, inSameDayAs: today) else {
                resetConsumed()
                defaults.set(today, forKey: lastUpdatedDateKey)
                return
            }
        } else {
            defaults.set(today, forKey: lastUpdatedDateKey)
        }
    }
}
