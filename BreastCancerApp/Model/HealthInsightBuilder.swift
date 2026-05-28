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

    // MARK: - Public entry point

    func buildInsights(filter: InsightDateFilter = .currentWeek) -> [HealthInsight] {
        let templates = HealthInsightResponse.loadFromFile()
        guard !templates.isEmpty else { return [] }
        return templates.map { template in
            switch template.type {
            case .hydration: return buildHydrationInsight(from: template, filter: filter)
            case .exercise: return buildExerciseInsight(from: template, filter: filter)
            case .medication: return buildMedicationInsight(from: template, filter: filter)
            case .symptoms: return buildSymptomsInsight(from: template, filter: filter)
            }
        }
    }

    // MARK: - Static formatter

    static func formatHydrationAmount(_ amountML: Int) -> String {
        if amountML < 1000 { return "\(amountML) ml" }
        let liters = Double(amountML) / 1000.0
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        let formatted = formatter.string(from: NSNumber(value: liters))
            ?? String(format: "%.1f", liters)
        return "\(formatted) L"
    }

    // MARK: - Hydration

    private func buildHydrationInsight(
        from template: HealthInsight,
        filter: InsightDateFilter
    ) -> HealthInsight {
        let dates = resolveDates(for: filter)
        let elapsedDates = elapsed(dates)
        let dailyValues = dates.map { HydrationDataManager.shared.getTotalForDate($0) }
        let elapsedValues = elapsedDates.map { HydrationDataManager.shared.getTotalForDate($0) }
        let goalML = max(
            UserDefaults.standard.integer(forKey: hydrationGoalKey),
            defaultHydrationGoalML
        )

        // Total hydration for the selected week (only elapsed days)
        let weekTotalML = elapsedValues.reduce(0, +)

        // Average per elapsed day to avoid dividing by future days
        let averageML = elapsedDates.isEmpty ? 0 : weekTotalML / elapsedDates.count

        // Show completed hydration for the week instead of just today
        let completedValue = "Completed: \(Self.formatHydrationAmount(weekTotalML))"

        return HealthInsight(
            type: .hydration,
            title: template.title,
            subtitle: "Goal: \(Self.formatHydrationAmount(goalML))",
            mainValue: Self.formatHydrationAmount(averageML),
            completedValue: completedValue,
            dailyValues: dailyValues
        )
    }

    // MARK: - Medication

    private func buildMedicationInsight(
        from template: HealthInsight,
        filter: InsightDateFilter
    ) -> HealthInsight {
        let dates = resolveDates(for: filter)
        let elapsedDates = elapsed(dates)
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
            subtitle: filter.subtitlePeriod,
            mainValue: "\(adherence)%",
            medicationTaken: "\(taken) doses taken",
            medicationMissed: "· \(missed) missed",
            dailyValues: statusValues
        )
    }

    // MARK: - Exercise

    private func buildExerciseInsight(
        from template: HealthInsight,
        filter: InsightDateFilter
    ) -> HealthInsight {
        let dates = resolveDates(for: filter)
        let completedByDay = dates.map { UserActivityStore.shared.completedExercises(on: $0) }
        let activeDays = completedByDay.filter { !$0.isEmpty }.count
        let totalCount = completedByDay.reduce(0) { $0 + $1.count }

        // 1 = exercised, 0 = did not exercise, -1 = future day
        let statusValues = dates.map { date -> Int in
            guard date <= calendar.startOfDay(for: Date()) else { return -1 }
            return UserActivityStore.shared.completedExercises(on: date).isEmpty ? 0 : 1
        }

        let todayCount: Int
        switch filter {
        case .currentWeek: todayCount = UserActivityStore.shared.completedExercises(on: Date()).count
        case .week: todayCount = 0
        }

        return HealthInsight(
            type: .exercise,
            title: template.title,
            subtitle: filter.subtitlePeriod,
            mainValue: "\(activeDays) / 7",
            secondaryValue: "Days active",
            medicationTaken: "\(totalCount) exercises done",
            medicationMissed: filter == .currentWeek ? "· \(todayCount) today" : "",
            dailyValues: statusValues
        )
    }

    // MARK: - Symptoms

    private func buildSymptomsInsight(
        from template: HealthInsight,
        filter: InsightDateFilter
    ) -> HealthInsight {
        let dates = resolveDates(for: filter)
        let source = SymptomDataSource.shared
        let dailyValues = dates.map { date in
            source.getSymptomLogs(on: date).map(\.severity).max() ?? 0
        }
        return HealthInsight(
            type: .symptoms,
            title: template.title,
            subtitle: "\(filter.subtitlePeriod) · Highest severity",
            detailText: template.detailText,
            dailyValues: dailyValues
        )
    }

    // MARK: - Date resolution

    func resolveDates(for filter: InsightDateFilter) -> [Date] {
        let anchorDate: Date
        switch filter {
        case .currentWeek: anchorDate = Date()
        case let .week(picked): anchorDate = picked
        }
        let (monday, _) = filter.weekBounds(for: anchorDate)
        return (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    // MARK: - Private helpers

    private func elapsed(_ dates: [Date]) -> [Date] {
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
