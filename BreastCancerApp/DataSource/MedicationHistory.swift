import Foundation

class MedicationHistory {
    static let shared = MedicationHistory()

    private let repository: MedicationHistoryRepository
    private var history: [String: MedicationHistoryEntry]

    init(repository: MedicationHistoryRepository = FirestoreMedicationHistoryRepository()) {
        self.repository = repository
        self.history = repository.loadHistory()

        if history.isEmpty {
            loadDummyHistoryData()
        }
        initializeTodayIfNeeded()
        persist()
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
        let taken = medications.filter { $0.isTaken }.count
        let goal = medications.count

        let stableId = history[key]?.id ?? key
        history[key] = MedicationHistoryEntry(
            id: stableId,
            date: date,
            medications: medications,
            taken: taken,
            goal: goal
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

    func initializeTodayIfNeeded() {
        let today = Date()
        let key = dateKey(from: today)
        guard history[key] == nil else { return }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        var todayMedications: [Medication] = []

        todayMedications.append(Medication(name: "Aspirin", note: "Take with food", time: "8:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true))
        todayMedications.append(Medication(name: "Vitamin D", note: "Morning supplement", time: "9:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true))
        todayMedications.append(Medication(name: "Blood Pressure Med", note: "", time: "12:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true))
        todayMedications.append(Medication(name: "Thyroid Medicine", note: "Take on empty stomach", time: "7:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true))
        todayMedications.append(Medication(name: "Allergy Medicine", note: "Only if needed", time: "10:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true))

        if weekday == 2 {
            todayMedications.append(Medication(name: "Omega-3", note: "", time: "6:00 PM", repeatOption: "Every Mon", isTaken: false, reminderEnabled: false))
        }
        if weekday == 4 {
            todayMedications.append(Medication(name: "Calcium Supplement", note: "Take with meal", time: "1:00 PM", repeatOption: "Every Wed", isTaken: false, reminderEnabled: true))
        }
        if weekday == 6 {
            todayMedications.append(Medication(name: "Vitamin B12", note: "", time: "8:30 AM", repeatOption: "Every Fri", isTaken: false, reminderEnabled: true))
        }

        saveMedications(todayMedications, for: today)
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
