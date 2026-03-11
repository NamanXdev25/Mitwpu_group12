import Foundation

extension Notification.Name {
    static let hydrationDataUpdated = Notification.Name("HydrationDataUpdated")
    static let medicationDataUpdated = Notification.Name("MedicationDataUpdated")
    static let symptomDataUpdated = Notification.Name("SymptomDataUpdated")
    static let exerciseDataUpdated = Notification.Name("ExerciseDataUpdated")
}

struct HealthInsightBuilder {
    private let calendar = Calendar.current
    private let hydrationGoalKey = "care_hydration_goal_ml"
    private let defaultHydrationGoalML = 3000

    func buildInsights() -> [HealthInsight] {
        let templates = HealthInsightResponse.loadFromFile()
        guard !templates.isEmpty else { return [] }

        return templates.map { template in
            switch template.type {
            case .hydration:
                return buildHydrationInsight(from: template)
            case .exercise:
                return buildExerciseInsight(from: template)
            case .medication:
                return buildMedicationInsight(from: template)
            case .symptoms:
                return buildSymptomsInsight(from: template)
            }
        }
    }

    static func formatHydrationAmount(_ amountML: Int) -> String {
        if amountML < 1000 {
            return "\(amountML) ml"
        }

        let liters = Double(amountML) / 1000.0
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        let formatted = formatter.string(from: NSNumber(value: liters)) ?? String(format: "%.1f", liters)
        return "\(formatted) L"
    }

    private func buildHydrationInsight(from template: HealthInsight) -> HealthInsight {
        let dates = weekDates()
        let elapsedDates = elapsedWeekDates(from: dates)
        let dailyValues = dates.map { HydrationDataManager.shared.getTotalForDate($0) }
        let elapsedValues = elapsedDates.map { HydrationDataManager.shared.getTotalForDate($0) }
        let todayTotal = HydrationDataManager.shared.getTotalForDate(Date())
        let goalML = max(UserDefaults.standard.integer(forKey: hydrationGoalKey), defaultHydrationGoalML)
        let averageML = elapsedValues.isEmpty ? 0 : elapsedValues.reduce(0, +) / elapsedValues.count

        return HealthInsight(
            type: .hydration,
            title: template.title,
            subtitle: "Goal: \(Self.formatHydrationAmount(goalML))",
            mainValue: Self.formatHydrationAmount(averageML),
            completedValue: "Completed: \(Self.formatHydrationAmount(todayTotal))",
            dailyValues: dailyValues
        )
    }

    private func buildMedicationInsight(from template: HealthInsight) -> HealthInsight {
        let dates = weekDates()
        let elapsedDates = elapsedWeekDates(from: dates)
        let allHistory = MedicationHistory.shared.getAllHistory()

        let statusValues = dates.map { date -> Int in
            guard date <= calendar.startOfDay(for: Date()) else { return -1 }
            guard let entry = historyEntry(for: date, in: allHistory) else { return -1 }
            guard entry.goal > 0 else { return -1 }
            return entry.taken >= entry.goal ? 1 : 0
        }

        let elapsedEntries = elapsedDates.compactMap { historyEntry(for: $0, in: allHistory) }
        let taken = elapsedEntries.reduce(0) { $0 + $1.taken }
        let goal = elapsedEntries.reduce(0) { $0 + $1.goal }
        let missed = max(goal - taken, 0)
        let adherence = goal == 0 ? 0 : Int((Double(taken) / Double(goal) * 100).rounded())

        return HealthInsight(
            type: .medication,
            title: template.title,
            subtitle: "This week",
            mainValue: "\(adherence)%",
            medicationTaken: "\(taken) doses taken",
            medicationMissed: "· \(missed) missed",
            dailyValues: statusValues
        )
    }

    private func buildExerciseInsight(from template: HealthInsight) -> HealthInsight {
        let dates = weekDates()
        let completedByDay = dates.map { UserActivityStore.shared.completedExercises(on: $0) }
        let activeDays = completedByDay.filter { !$0.isEmpty }.count
        let completedExerciseCount = completedByDay.reduce(0) { $0 + $1.count }
        let todayCount = UserActivityStore.shared.completedExercises(on: Date()).count
        let statusValues = dates.map { date -> Int in
            guard date <= calendar.startOfDay(for: Date()) else { return -1 }
            return UserActivityStore.shared.completedExercises(on: date).isEmpty ? 0 : 1
        }

        return HealthInsight(
            type: .exercise,
            title: template.title,
            subtitle: "This week",
            mainValue: "\(activeDays) / 7",
            secondaryValue: "Days active",
            medicationTaken: "\(completedExerciseCount) exercises done",
            medicationMissed: "· \(todayCount) today",
            dailyValues: statusValues
        )
    }

    private func buildSymptomsInsight(from template: HealthInsight) -> HealthInsight {
        let dates = weekDates()
        let source = SymptomDataSource.shared
        let dailyValues = dates.map { date in
            source.getSymptomLogs(on: date).map(\.severity).max() ?? 0
        }

        return HealthInsight(
            type: .symptoms,
            title: template.title,
            subtitle: "This week · Highest severity",
            detailText: template.detailText,
            dailyValues: dailyValues
        )
    }

    private func weekDates() -> [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today) ?? today

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: monday)
        }
    }

    private func elapsedWeekDates(from dates: [Date]) -> [Date] {
        let today = calendar.startOfDay(for: Date())
        return dates.filter { $0 <= today }
    }

    private func historyEntry(
        for date: Date,
        in history: [MedicationHistoryEntry]
    ) -> MedicationHistoryEntry? {
        history.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
}
