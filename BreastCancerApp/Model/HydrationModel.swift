//
//  HydrationModel.swift
//  BreastCancerApp
//
//  Created by Gayatri Goundadkar on 05/01/26.
//

import Foundation

struct HydrationModel {

    // MARK: - UserDefaults Keys
    private static let consumedKey = "hydration_consumed"
    private static let goalKey = "hydration_goal"
    private static let cupSizeKey = "hydration_cup_size"
    private static let lastUpdatedDateKey = "hydration_last_date"

    // MARK: - Defaults
    static let defaultGoal: Double = 3.0      // Liters
    static let defaultCupSize: Double = 0.2   // 200 ml in liters

    // MARK: - Getters

    static func currentGoal() -> Double {
        let value = UserDefaults.standard.double(forKey: goalKey)
        return value == 0 ? defaultGoal : value
    }

    static func currentCupSize() -> Double {
        let value = UserDefaults.standard.double(forKey: cupSizeKey)
        return value == 0 ? defaultCupSize : value
    }

    static func consumedToday() -> Double {
        checkForDailyReset()
        return UserDefaults.standard.double(forKey: consumedKey)
    }

    // MARK: - Setters

    static func setGoal(_ goal: Double) {
        UserDefaults.standard.set(goal, forKey: goalKey)
    }

    static func setCupSize(_ cupSize: Double) {
        UserDefaults.standard.set(cupSize, forKey: cupSizeKey)
    }

    static func addCup() {
        checkForDailyReset()
        let current = consumedToday()
        let updated = current + currentCupSize()
        UserDefaults.standard.set(updated, forKey: consumedKey)
    }

    static func resetConsumed() {
        UserDefaults.standard.set(0.0, forKey: consumedKey)
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
