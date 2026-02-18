import Foundation

enum TreatmentType: String, CaseIterable {
    case none = "Select treatment"
    case chemotherapy = "Chemotherapy"
    case surgery = "Surgery"
    case radiation = "Radiation"
    case hormoneTherapy = "Hormone Therapy"
}

enum PhaseState {
    case editing
    case saved
}

struct TreatmentPhaseModel {
    var treatmentType: TreatmentType = .none
    var startDate: Date? = nil
    var duration: String = ""
    var currentDayInCycle: String = ""
    var state: PhaseState = .editing
}

struct TreatmentModel {
    var phases: [TreatmentPhaseModel] = []
    var status: String = "Not Started"
}
