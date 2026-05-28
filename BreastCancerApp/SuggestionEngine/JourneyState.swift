import Foundation

// MARK: - Codable phase state (persisted to UserDefaults)

struct PersistedPhaseState: Codable {
    var treatmentTypeRaw: String
    var startDate: Date?
    var duration: String
    var isSaved: Bool
    var statusRaw: String
}

// MARK: - Codable post-treatment state (persisted to UserDefaults)

struct PersistedPostTreatmentState: Codable {
    var selectedDate: Date?
    var selectedSymptoms: [String]
    var isSaved: Bool
}

// MARK: - Codable journey snapshot (full state for repository sync)

struct PersistedJourneySnapshot: Codable {
    var isDiagnosisCompleted: Bool
    var isWaitCompleted: Bool
    var isTreatmentCompleted: Bool
    var currentStepTitle: String
    var currentTreatmentName: String
    var persistedTreatmentBadge: String
    var phaseStates: [PersistedPhaseState]
    var postTreatment: PersistedPostTreatmentState
    var diagnosisDate: Date?
    var waitDaysInput: Int?
    var waitSymptoms: [String]
}

final class JourneyState {
    static let shared = JourneyState()

    private var saveWorkItem: DispatchWorkItem?

    private init() {
        restore()
    }

    // MARK: - Notification name

    static let didChangeNotification = Notification.Name("JourneyStateDidChange")

    // MARK: - Repository

    private lazy var repository: JourneyRepository = RepositoryFactory.makeJourneyRepository()

    // MARK: - Section unlock flags

    private(set) var isDiagnosisCompleted = false
    private(set) var isWaitCompleted = false
    private(set) var isTreatmentCompleted = false

    // MARK: - Journey summary for Home screen

    private(set) var currentStepTitle: String = "Diagnosed"
    private(set) var currentTreatmentName: String = "Not started yet"

    // MARK: - Treatment phase persistence (read by JourneyViewController on load)

    private(set) var persistedPhaseStates: [PersistedPhaseState] = []
    private(set) var persistedTreatmentBadge: String = "notStarted"

    // MARK: - Post-treatment persistence (read by JourneyViewController on load)

    private(set) var persistedPostTreatment = PersistedPostTreatmentState(
        selectedDate: nil, selectedSymptoms: [], isSaved: false
    )

    // MARK: - Detailed state properties requirements

    private(set) var diagnosisDate: Date?
    private(set) var waitDaysInput: Int?
    private(set) var waitSymptoms: [String] = []

    // MARK: - Persist / Restore

    private func save() {
        saveWorkItem?.cancel()

        let snapshot = PersistedJourneySnapshot(
            isDiagnosisCompleted: isDiagnosisCompleted,
            isWaitCompleted: isWaitCompleted,
            isTreatmentCompleted: isTreatmentCompleted,
            currentStepTitle: currentStepTitle,
            currentTreatmentName: currentTreatmentName,
            persistedTreatmentBadge: persistedTreatmentBadge,
            phaseStates: persistedPhaseStates,
            postTreatment: persistedPostTreatment,
            diagnosisDate: diagnosisDate,
            waitDaysInput: waitDaysInput,
            waitSymptoms: waitSymptoms
        )

        let workItem = DispatchWorkItem { [weak self] in
            self?.repository.saveState(snapshot)
        }
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }

    private func restore() {
        guard let snapshot = repository.loadState() else { return }

        isDiagnosisCompleted = snapshot.isDiagnosisCompleted
        isWaitCompleted = snapshot.isWaitCompleted
        isTreatmentCompleted = snapshot.isTreatmentCompleted
        currentStepTitle = snapshot.currentStepTitle
        currentTreatmentName = snapshot.currentTreatmentName
        persistedTreatmentBadge = snapshot.persistedTreatmentBadge
        persistedPhaseStates = snapshot.phaseStates
        persistedPostTreatment = snapshot.postTreatment
        diagnosisDate = snapshot.diagnosisDate
        waitDaysInput = snapshot.waitDaysInput
        waitSymptoms = snapshot.waitSymptoms

        if currentTreatmentName == "Not started yet" || currentTreatmentName.isEmpty,
           !persistedPhaseStates.isEmpty {
            let latestSaved = persistedPhaseStates
                .filter { $0.isSaved && $0.treatmentTypeRaw != "none" && !$0.treatmentTypeRaw.isEmpty }
                .last
            if let name = latestSaved?.treatmentTypeRaw {
                currentTreatmentName = name
            }
        }
    }

    // MARK: - Phase state persistence (called by JourneyViewController)

    func savePhaseStates(_ states: [PersistedPhaseState], badgeStatus: String) {
        persistedPhaseStates = states
        persistedTreatmentBadge = badgeStatus
        save()
    }

    func savePostTreatmentState(_ state: PersistedPostTreatmentState) {
        persistedPostTreatment = state
        save()
    }

    func saveDiagnosisState(date: Date?) {
        diagnosisDate = date
        save()
    }

    func saveWaitState(days: Int?, symptoms: [String]) {
        waitDaysInput = days
        waitSymptoms = symptoms
        save()
    }

    // MARK: - Mutation helpers

    func completeDiagnosis() {
        isDiagnosisCompleted = true
        currentStepTitle = "Waiting for Result"
        save(); post()
    }

    func completeWait() {
        isWaitCompleted = true
        currentStepTitle = "Treatment"
        save(); post()
    }

    func completeTreatment(phaseName: String) {
        isTreatmentCompleted = true
        currentTreatmentName = phaseName
        currentStepTitle = "Post-Treatment"
        save(); post()
    }

    func updateTreatmentPhaseName(_ name: String) {
        currentTreatmentName = name
        save(); post()
    }

    func completePostTreatment() {
        currentStepTitle = "Post-Treatment"
        save(); post()
    }

    func resetDiagnosis() {
        isDiagnosisCompleted = false
        isWaitCompleted = false
        isTreatmentCompleted = false
        currentStepTitle = "Diagnosed"
        persistedPhaseStates = []
        persistedTreatmentBadge = "notStarted"
        currentTreatmentName = "Not started yet"
        persistedPostTreatment = PersistedPostTreatmentState(selectedDate: nil, selectedSymptoms: [], isSaved: false)
        diagnosisDate = nil
        waitDaysInput = nil
        waitSymptoms = []
        save(); post()
    }

    func resetWait() {
        isWaitCompleted = false
        isTreatmentCompleted = false
        currentStepTitle = isDiagnosisCompleted ? "Waiting for Result" : "Diagnosed"
        persistedPhaseStates = []
        persistedTreatmentBadge = "notStarted"
        currentTreatmentName = "Not started yet"
        persistedPostTreatment = PersistedPostTreatmentState(selectedDate: nil, selectedSymptoms: [], isSaved: false)
        waitDaysInput = nil
        waitSymptoms = []
        save(); post()
    }

    func resetTreatment() {
        isTreatmentCompleted = false
        persistedPhaseStates = []
        persistedTreatmentBadge = "notStarted"
        currentTreatmentName = "Not started yet"
        currentStepTitle = isWaitCompleted ? "Treatment" : "Waiting for Result"
        persistedPostTreatment = PersistedPostTreatmentState(selectedDate: nil, selectedSymptoms: [], isSaved: false)
        save(); post()
    }

    private func post() {
        NotificationCenter.default.post(name: JourneyState.didChangeNotification, object: nil)
    }
}
