//
//  JourneyState.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 07/03/26.
//

import Foundation

// MARK: - Codable phase state (persisted to UserDefaults)
struct PersistedPhaseState: Codable {
    var treatmentTypeRaw: String
    var startDate: Date?
    var duration: String
    var isSaved: Bool
    var statusRaw: String   // "notStarted" | "inProgress" | "completed"
}

// MARK: - Codable post-treatment state (persisted to UserDefaults)
struct PersistedPostTreatmentState: Codable {
    var selectedDate: Date?
    var selectedSymptoms: [String]
    var isSaved: Bool
}

final class JourneyState {

    static let shared = JourneyState()
    private init() { restore() }

    // MARK: - Notification name
    static let didChangeNotification = Notification.Name("JourneyStateDidChange")

    // MARK: - Persistence keys
    private let kDiagnosisCompleted  = "js_diagnosisCompleted"
    private let kWaitCompleted       = "js_waitCompleted"
    private let kTreatmentCompleted  = "js_treatmentCompleted"
    private let kStepTitle           = "js_stepTitle"
    private let kTreatmentName       = "js_treatmentName"
    private let kPhaseStates         = "js_phaseStates"
    private let kTreatmentBadge      = "js_treatmentBadge"
    private let kPostTreatment       = "js_postTreatment"

    // MARK: - Section unlock flags
    private(set) var isDiagnosisCompleted   = false
    private(set) var isWaitCompleted        = false
    private(set) var isTreatmentCompleted   = false

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

    // MARK: - Persist / Restore
    private func save() {
        let d = UserDefaults.standard
        d.set(isDiagnosisCompleted,  forKey: kDiagnosisCompleted)
        d.set(isWaitCompleted,       forKey: kWaitCompleted)
        d.set(isTreatmentCompleted,  forKey: kTreatmentCompleted)
        d.set(currentStepTitle,      forKey: kStepTitle)
        d.set(currentTreatmentName,  forKey: kTreatmentName)
        d.set(persistedTreatmentBadge, forKey: kTreatmentBadge)

        if let data = try? JSONEncoder().encode(persistedPhaseStates) {
            d.set(data, forKey: kPhaseStates)
        }
        if let data = try? JSONEncoder().encode(persistedPostTreatment) {
            d.set(data, forKey: kPostTreatment)
        }
    }

    private func restore() {
        let d = UserDefaults.standard
        isDiagnosisCompleted  = d.bool(forKey: kDiagnosisCompleted)
        isWaitCompleted       = d.bool(forKey: kWaitCompleted)
        isTreatmentCompleted  = d.bool(forKey: kTreatmentCompleted)
        currentStepTitle      = d.string(forKey: kStepTitle)      ?? "Diagnosed"
        currentTreatmentName  = d.string(forKey: kTreatmentName)  ?? "Not started yet"
        persistedTreatmentBadge = d.string(forKey: kTreatmentBadge) ?? "notStarted"

        if let data = d.data(forKey: kPhaseStates),
           let decoded = try? JSONDecoder().decode([PersistedPhaseState].self, from: data) {
            persistedPhaseStates = decoded
        }
        if let data = d.data(forKey: kPostTreatment),
           let decoded = try? JSONDecoder().decode(PersistedPostTreatmentState.self, from: data) {
            persistedPostTreatment = decoded
        }
    }

    // MARK: - Phase state persistence (called by JourneyViewController)
    func savePhaseStates(_ states: [PersistedPhaseState], badgeStatus: String) {
        persistedPhaseStates    = states
        persistedTreatmentBadge = badgeStatus
        save()
    }

    func savePostTreatmentState(_ state: PersistedPostTreatmentState) {
        persistedPostTreatment = state
        save()
    }

    // MARK: - Mutation helpers
    func completeDiagnosis() {
        isDiagnosisCompleted = true
        currentStepTitle     = "Waiting for Result"
        save(); post()
    }

    func completeWait() {
        isWaitCompleted  = true
        currentStepTitle = "Treatment"
        save(); post()
    }

    func completeTreatment(phaseName: String) {
        isTreatmentCompleted   = true
        currentTreatmentName   = phaseName
        currentStepTitle       = "Post-Treatment"
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
        isWaitCompleted      = false
        isTreatmentCompleted = false
        currentStepTitle     = "Diagnosed"
        // Clear all phase + post-treatment state when diagnosis resets
        persistedPhaseStates    = []
        persistedTreatmentBadge = "notStarted"
        persistedPostTreatment  = PersistedPostTreatmentState(selectedDate: nil, selectedSymptoms: [], isSaved: false)
        save(); post()
    }

    func resetWait() {
        isWaitCompleted      = false
        isTreatmentCompleted = false
        currentStepTitle     = isDiagnosisCompleted ? "Waiting for Result" : "Diagnosed"
        // Clear phase + post-treatment state when wait resets
        persistedPhaseStates    = []
        persistedTreatmentBadge = "notStarted"
        persistedPostTreatment  = PersistedPostTreatmentState(selectedDate: nil, selectedSymptoms: [], isSaved: false)
        save(); post()
    }

    func resetTreatment() {
        isTreatmentCompleted    = false
        persistedTreatmentBadge = "notStarted"
        currentStepTitle        = isWaitCompleted ? "Treatment" : "Waiting for Result"
        save(); post()
    }

    private func post() {
        NotificationCenter.default.post(name: JourneyState.didChangeNotification, object: nil)
    }
}
