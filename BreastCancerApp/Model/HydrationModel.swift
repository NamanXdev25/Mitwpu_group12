import Foundation

struct HydrationModel {

    private static let consumedKey = "hydration_consumed"
    private static let goalKey = "hydration_goal"
    private static let cupSizeKey = "hydration_cup_size"
    private static let lastUpdatedDateKey = "hydration_last_date"

    static let defaultGoal: Double = 3.0
    static let defaultCupSize: Double = 0.2

    static func currentGoal() -> Double {
        let value = UserDefaults.standard.double(forKey: goalKey)
        return value == 0 ? defaultGoal : value
    }

    static func currentCupSize() -> Double {
        let value = UserDefaults.standard.double(forKey: cupSizeKey)
        return value == 0 ? defaultCupSize : value
    }

    static func consumedTodayML() -> Int {
        checkForDailyReset()
        return UserDefaults.standard.integer(forKey: consumedKey)
    }

    static func consumedToday() -> Double {
        Double(consumedTodayML()) / 1000.0
    }

    static func setGoal(_ goal: Double) {
        UserDefaults.standard.set(goal, forKey: goalKey)
    }

    static func setCupSize(_ cupSize: Double) {
        UserDefaults.standard.set(cupSize, forKey: cupSizeKey)
    }

    static func addWaterML(_ ml: Int) {
        checkForDailyReset()
        let current = consumedTodayML()
        UserDefaults.standard.set(current + ml, forKey: consumedKey)
    }

    static func resetConsumed() {
        UserDefaults.standard.set(0, forKey: consumedKey)
    }

    private static func checkForDailyReset() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = UserDefaults.standard.object(forKey: lastUpdatedDateKey) as? Date {
            if !calendar.isDate(lastDate, inSameDayAs: today) {
                resetConsumed()
                UserDefaults.standard.set(today, forKey: lastUpdatedDateKey)
            }
        } else {
            UserDefaults.standard.set(today, forKey: lastUpdatedDateKey)
        }
    }
}
