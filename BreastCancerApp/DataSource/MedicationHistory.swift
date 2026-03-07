import Foundation

class MedicationHistory {
    static let shared = MedicationHistory()

    private let repository: MedicationHistoryRepository
    private var history: [String: MedicationHistoryEntry]
    private let demoCleanupFlagKey = "medication_demo_history_cleanup_v1"
    private let demoMedicationNames: Set<String> = [
        "Aspirin",
        "Vitamin D",
        "Blood Pressure Med",
        "Thyroid Medicine",
        "Allergy Medicine",
        "Omega-3",
        "Calcium Supplement",
        "Vitamin B12"
    ]

    init(repository: MedicationHistoryRepository = RepositoryFactory.makeMedicationHistoryRepository()) {
        self.repository = repository
        self.history = repository.loadHistory()
        var didMutate = false

        if normalizeStoredDailyCountsIfNeeded() {
            didMutate = true
        }
        if purgeLegacyDemoHistoryIfNeeded() {
            didMutate = true
        }
        if initializeTodayIfNeeded() {
            didMutate = true
        }
        if didMutate {
            persist()
        }
    }

    private func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func persist() {
        repository.saveHistory(history)
    }

    func updateProgress(date: Date, taken: Int, goal: Int) {
        let key = dateKey(from: date)

        if var entry = history[key] {
            entry.taken = taken
            entry.goal = goal
            history[key] = entry
        } else {
            history[key] = MedicationHistoryEntry(
                id: key,
                date: date,
                medications: [],
                taken: taken,
                goal: goal
            )
        }

        persist()
    }

    func saveMedications(_ medications: [Medication], for date: Date) {
        let key = dateKey(from: date)
        let dailyCounts = scheduledCounts(for: medications, on: date)

        let stableId = history[key]?.id ?? key
        history[key] = MedicationHistoryEntry(
            id: stableId,
            date: date,
            medications: medications,
            taken: dailyCounts.taken,
            goal: dailyCounts.goal
        )

        persist()
    }

    func getHistory(for date: Date) -> MedicationHistoryEntry? {
        let key = dateKey(from: date)
        return history[key]
    }

    func getAllHistory() -> [MedicationHistoryEntry] {
        Array(history.values).sorted { $0.date > $1.date }
    }

    @discardableResult
    func initializeTodayIfNeeded() -> Bool {
        let today = Date()
        let key = dateKey(from: today)
        guard history[key] == nil else { return false }

        history[key] = MedicationHistoryEntry(
            id: key,
            date: today,
            medications: [],
            taken: 0,
            goal: 0
        )
        return true
    }

    private func purgeLegacyDemoHistoryIfNeeded() -> Bool {
        guard AppBackend.current == .supabase else { return false }

        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: demoCleanupFlagKey) else { return false }
        defer { defaults.set(true, forKey: demoCleanupFlagKey) }

        let allMedications = history.values.flatMap(\.medications)
        guard allMedications.count >= 120 else { return false }

        let names = Set(allMedications.map(\.name))
        guard !names.isEmpty, names.isSubset(of: demoMedicationNames) else { return false }

        history.removeAll()
        return true
    }

    private func scheduledCounts(for medications: [Medication], on date: Date) -> (taken: Int, goal: Int) {
        let scheduled = medications.filter { $0.isScheduledFor(date: date) }
        let taken = scheduled.filter { $0.isTaken }.count
        return (taken: taken, goal: scheduled.count)
    }

    private func normalizeStoredDailyCountsIfNeeded() -> Bool {
        var didMutate = false

        for key in Array(history.keys) {
            guard var entry = history[key] else { continue }
            let normalized = scheduledCounts(for: entry.medications, on: entry.date)
            guard entry.taken != normalized.taken || entry.goal != normalized.goal else { continue }

            entry.taken = normalized.taken
            entry.goal = normalized.goal
            history[key] = entry
            didMutate = true
        }

        return didMutate
    }

    private func loadDummyHistoryData() {
        let calendar = Calendar.current
        let today = Date()

        for daysAgo in 1...30 {
            guard let pastDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: pastDate)
            var dayMedications: [Medication] = []

            dayMedications.append(Medication(name: "Aspirin", note: "Take with food", time: "8:00 AM", repeatOption: "Every Day", isTaken: Bool.random(), reminderEnabled: true))
            dayMedications.append(Medication(name: "Vitamin D", note: "Morning supplement", time: "9:00 AM", repeatOption: "Every Day", isTaken: Bool.random(), reminderEnabled: true))
            dayMedications.append(Medication(name: "Blood Pressure Med", note: "", time: "12:00 PM", repeatOption: "Every Day", isTaken: Bool.random(), reminderEnabled: true))
            dayMedications.append(Medication(name: "Thyroid Medicine", note: "Take on empty stomach", time: "7:00 AM", repeatOption: "Every Day", isTaken: Bool.random(), reminderEnabled: true))
            dayMedications.append(Medication(name: "Allergy Medicine", note: "Only if needed", time: "10:00 PM", repeatOption: "Every Day", isTaken: Bool.random(), reminderEnabled: true))

            if weekday == 2 {
                dayMedications.append(Medication(name: "Omega-3", note: "", time: "6:00 PM", repeatOption: "Every Mon", isTaken: Bool.random(), reminderEnabled: false))
            }
            if weekday == 4 {
                dayMedications.append(Medication(name: "Calcium Supplement", note: "Take with meal", time: "1:00 PM", repeatOption: "Every Wed", isTaken: Bool.random(), reminderEnabled: true))
            }
            if weekday == 6 {
                dayMedications.append(Medication(name: "Vitamin B12", note: "", time: "8:30 AM", repeatOption: "Every Fri", isTaken: Bool.random(), reminderEnabled: true))
            }

            saveMedications(dayMedications, for: pastDate)
        }
    }

    func reloadDummyData() {
        history.removeAll()
        loadDummyHistoryData()
        initializeTodayIfNeeded()
        persist()
    }
}
