
import Foundation

class SymptomDataSource {
    static let shared = SymptomDataSource()

    private let repository: SymptomRepository
    private let defaultSymptomIDs: Set<String> = ["fatigue", "nausea", "pain"]

    private init(repository: SymptomRepository = RepositoryFactory.makeSymptomRepository()) {
        self.repository = repository
        loadSymptomsFromJSON()
        loadPersistedState()
    }

    private var allSymptoms: [Symptom] = []
    private var todayLogs: [SymptomLog] = []
    private var currentUserSymptomsOrder: [String] = []

    private func loadSymptomsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Symptoms", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let symptomsData = try? JSONDecoder().decode(SymptomsData.self, from: data) else {
            return
        }

        allSymptoms = symptomsData.symptoms
    }

    private func loadPersistedState() {
        currentUserSymptomsOrder = repository.loadUserSymptomIDs()

        if currentUserSymptomsOrder.isEmpty {
            let defaults = allSymptoms.filter {
                defaultSymptomIDs.contains($0.id.lowercased()) ||
                defaultSymptomIDs.contains($0.name.lowercased())
            }
            currentUserSymptomsOrder = defaults.map { $0.id }
            persistUserSymptomIDs()
        }

        applyUserSymptomIDsToMasterList(currentUserSymptomsOrder)

        let persistedLogs = repository.loadLogs()
        let cleanedLogs = removeLegacySeedLogsIfNeeded(from: persistedLogs)
        todayLogs = cleanedLogs
        if cleanedLogs.count != persistedLogs.count {
            persistLogs()
        }
    }

    private func removeLegacySeedLogsIfNeeded(from logs: [SymptomLog]) -> [SymptomLog] {
        guard !logs.isEmpty else { return logs }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        struct SeedSignature: Hashable {
            let symptomId: String
            let severity: Int
            let dayOffset: Int
        }

        let legacySeedSignatures: Set<SeedSignature> = [
            SeedSignature(symptomId: "nausea", severity: 1, dayOffset: 1),
            SeedSignature(symptomId: "pain", severity: 3, dayOffset: 1),
            SeedSignature(symptomId: "fatigue", severity: 3, dayOffset: 3),
            SeedSignature(symptomId: "headache", severity: 2, dayOffset: 3),
            SeedSignature(symptomId: "nausea", severity: 4, dayOffset: 5),
            SeedSignature(symptomId: "pain", severity: 2, dayOffset: 7),
            SeedSignature(symptomId: "fatigue", severity: 4, dayOffset: 7),
            SeedSignature(symptomId: "insomnia", severity: 3, dayOffset: 10),
            SeedSignature(symptomId: "nausea", severity: 2, dayOffset: 12),
            SeedSignature(symptomId: "appetite_loss", severity: 3, dayOffset: 12),
            SeedSignature(symptomId: "fatigue", severity: 3, dayOffset: 14),
            SeedSignature(symptomId: "pain", severity: 4, dayOffset: 14),
            SeedSignature(symptomId: "headache", severity: 1, dayOffset: 17),
            SeedSignature(symptomId: "nausea", severity: 3, dayOffset: 19),
            SeedSignature(symptomId: "fatigue", severity: 4, dayOffset: 21),
            SeedSignature(symptomId: "insomnia", severity: 2, dayOffset: 21),
            SeedSignature(symptomId: "pain", severity: 3, dayOffset: 24),
            SeedSignature(symptomId: "nausea", severity: 2, dayOffset: 26),
            SeedSignature(symptomId: "appetite_loss", severity: 4, dayOffset: 26),
            SeedSignature(symptomId: "fatigue", severity: 2, dayOffset: 28),
            SeedSignature(symptomId: "headache", severity: 3, dayOffset: 30),
            SeedSignature(symptomId: "pain", severity: 2, dayOffset: 30)
        ]

        var removalIndices = Set<Int>()

        for (index, log) in logs.enumerated() {
            let trimmedNote = log.note.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedNote.isEmpty else { continue }

            let logDay = calendar.startOfDay(for: log.timestamp)
            let dayOffset = calendar.dateComponents([.day], from: logDay, to: today).day ?? 0
            guard dayOffset >= 1 else { continue }

            let signature = SeedSignature(
                symptomId: log.symptomId.lowercased(),
                severity: log.severity,
                dayOffset: dayOffset
            )
            if legacySeedSignatures.contains(signature) {
                removalIndices.insert(index)
            }
        }

        guard removalIndices.count >= 8 else { return logs }

        return logs.enumerated().compactMap { index, log in
            removalIndices.contains(index) ? nil : log
        }
    }

    private func applyUserSymptomIDsToMasterList(_ ids: [String]) {
        let idSet = Set(ids)
        for index in allSymptoms.indices {
            allSymptoms[index].isInUserList = idSet.contains(allSymptoms[index].id)
        }
    }

    private func persistLogs() {
        repository.saveLogs(todayLogs)
        NotificationCenter.default.post(name: .symptomDataUpdated, object: nil)
    }

    private func persistUserSymptomIDs() {
        repository.saveUserSymptomIDs(currentUserSymptomsOrder)
    }

    func getDescription(for symptomName: String) -> String {
        return allSymptoms.first(where: { $0.name == symptomName })?.description
            ?? "Track this symptom and discuss with your care team if it persists or worsens."
    }

    func getUserSymptoms() -> [Symptom] {
        let userSymptoms = allSymptoms.filter { $0.isInUserList }
        guard !currentUserSymptomsOrder.isEmpty else {
            return userSymptoms
        }

        var ordered: [Symptom] = []

        for id in currentUserSymptomsOrder {
            if let symptom = userSymptoms.first(where: { $0.id == id }) {
                ordered.append(symptom)
            }
        }

        for symptom in userSymptoms {
            if !ordered.contains(where: { $0.id == symptom.id }) {
                ordered.append(symptom)
            }
        }

        return ordered
    }

    func getAvailableSymptoms() -> [Symptom] {
        return allSymptoms.filter { !$0.isInUserList }
    }

    func addSymptomToUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = true

        if !currentUserSymptomsOrder.contains(symptomId) {
            currentUserSymptomsOrder.append(symptomId)
        }

        persistUserSymptomIDs()
    }

    func removeSymptomFromUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = false
        currentUserSymptomsOrder.removeAll { $0 == symptomId }
        persistUserSymptomIDs()
    }

    func updateUserSymptomsOrderInMemory(_ symptoms: [Symptom]) {
        currentUserSymptomsOrder = symptoms.map { $0.id }
        persistUserSymptomIDs()
    }

    func logSymptom(
        symptomId: String,
        symptomName: String,
        severity: Int,
        note: String = "",
        on date: Date = Date()
    ) {
        let log = SymptomLog(
            symptomId: symptomId,
            symptomName: symptomName,
            severity: severity,
            note: note,
            timestamp: timestampForLog(on: date)
        )
        todayLogs.append(log)
        persistLogs()
    }

    func getTodayLogs() -> [SymptomLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return todayLogs.filter { log in
            calendar.isDate(log.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
    }

    func deleteLog(logId: String) {
        todayLogs.removeAll { $0.id == logId }
        persistLogs()
    }

    func getSeverityText(for severity: Int) -> String {
        switch severity {
        case 0: return "Mild"
        case 1: return "Mild-Moderate"
        case 2: return "Moderate"
        case 3: return "Moderate-Severe"
        case 4: return "Severe"
        default: return "Unknown"
        }
    }

    func getSymptomLogDays() -> Set<Date> {
        let calendar = Calendar.current
        return Set(todayLogs.map { calendar.startOfDay(for: $0.timestamp) })
    }

    func getSymptomLogs(on date: Date) -> [SymptomLog] {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)

        return todayLogs.filter { log in
            let logDay = calendar.startOfDay(for: log.timestamp)
            return logDay == targetDay
        }.sorted { $0.timestamp > $1.timestamp }
    }

    private func timestampForLog(on date: Date) -> Date {
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let currentTime = calendar.dateComponents([.hour, .minute, .second], from: Date())

        var combined = DateComponents()
        combined.year = dayComponents.year
        combined.month = dayComponents.month
        combined.day = dayComponents.day
        combined.hour = currentTime.hour
        combined.minute = currentTime.minute
        combined.second = currentTime.second

        return calendar.date(from: combined) ?? date
    }
}
