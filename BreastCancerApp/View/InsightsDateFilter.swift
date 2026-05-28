//
//  InsightDateFilter.swift
//  BreastCancerApp
//
//  Created by Shloka on 16/03/26.
//
import Foundation

// MARK: - InsightDateFilter

enum InsightDateFilter: Equatable {
    /// Default — Mon–Sun of the current calendar week
    case currentWeek

    /// Mon–Sun of the week that contains the user-picked date
    case week(containing: Date)

    // MARK: - Nav bar title  e.g. "Mar 10 – Mar 16"

    var displayTitle: String {
        switch self {
        case .currentWeek:
            return "Health Insights"
        case let .week(anchorDate):
            let (mon, sun) = weekBounds(for: anchorDate)
            let fmt = DateFormatter()
            fmt.dateFormat = "MMM d"
            let monStr = fmt.string(from: mon)
            // Show year on the end date only when it differs from today's year
            let sunFmt = DateFormatter()
            let sunYear = Calendar.current.component(.year, from: sun)
            let thisYear = Calendar.current.component(.year, from: Date())
            sunFmt.dateFormat = sunYear == thisYear ? "MMM d" : "MMM d, yyyy"
            return "\(monStr) – \(sunFmt.string(from: sun))"
        }
    }

    // MARK: - Cell subtitle  e.g. "Mar 10 – Mar 16" or "This week"

    var subtitlePeriod: String {
        switch self {
        case .currentWeek: return "This week"
        case let .week(anchor):
            let (mon, sun) = weekBounds(for: anchor)
            let fmt = DateFormatter()
            fmt.dateFormat = "MMM d"
            return "\(fmt.string(from: mon)) – \(fmt.string(from: sun))"
        }
    }

    // MARK: - Whether a custom filter is active

    var isCustom: Bool {
        guard case let .week(anchor) = self else { return false }
        // Still "custom" even if the user happened to pick a date in the current week
        // — we treat any explicit pick as custom so the filled icon shows.
        let cal = Calendar.current
        return !cal.isDate(anchor, equalTo: Date(), toGranularity: .weekOfYear)
    }

    // MARK: - Helper: Monday and Sunday bounding a given date

    func weekBounds(for date: Date) -> (monday: Date, sunday: Date) {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: date)
        let weekday = cal.component(.weekday, from: startOfDay)
        let mondayOffset = (weekday + 5) % 7 // 0 when already Monday
        let monday = cal.date(byAdding: .day, value: -mondayOffset, to: startOfDay)!
        let sunday = cal.date(byAdding: .day, value: 6, to: monday)!
        return (monday, sunday)
    }
}
