import Foundation

struct HydrationModel {

    // MARK: - UserDefaults Keys
    private static let consumedKey = "hydration_consumed"      // Int (mL)
    private static let goalKey = "hydration_goal"              // Double (L)
    private static let cupSizeKey = "hydration_cup_size"       // Double (L)
    private static let lastUpdatedDateKey = "hydration_last_date"

    // MARK: - Defaults
    static let defaultGoal: Double = 3.0      // Liters
    static let defaultCupSize: Double = 0.2   // Liters (200 mL)

    // MARK: - Getters

    /// Daily goal in liters
    static func currentGoal() -> Double {
        let value = UserDefaults.standard.double(forKey: goalKey)
        return value == 0 ? defaultGoal : value
    }

    /// Cup size in liters
    static func currentCupSize() -> Double {
        let value = UserDefaults.standard.double(forKey: cupSizeKey)
        return value == 0 ? defaultCupSize : value
    }

    /// Consumed today in **milliliters**
    static func consumedTodayML() -> Int {
        checkForDailyReset()
        return UserDefaults.standard.integer(forKey: consumedKey)
    }

    /// Consumed today in liters (UI convenience)
    static func consumedToday() -> Double {
        Double(consumedTodayML()) / 1000.0
    }

    // MARK: - Setters

    static func setGoal(_ goal: Double) {
        UserDefaults.standard.set(goal, forKey: goalKey)
    }

    static func setCupSize(_ cupSize: Double) {
        UserDefaults.standard.set(cupSize, forKey: cupSizeKey)
    }

    /// ✅ Add water in **milliliters**
    static func addWaterML(_ ml: Int) {
        checkForDailyReset()
        let current = consumedTodayML()
        UserDefaults.standard.set(current + ml, forKey: consumedKey)
    }

    static func resetConsumed() {
        UserDefaults.standard.set(0, forKey: consumedKey)
    }

    // MARK: - Daily Reset Logic

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
