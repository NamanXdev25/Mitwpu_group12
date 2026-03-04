import Foundation

enum TreatmentType: String, CaseIterable {
    case none               = "Select treatment"
    case chemotherapy       = "Chemotherapy"
    case radiationTherapy   = "Radiation Therapy"
    case immunotherapy      = "Immunotherapy"
    case hormoneTherapy     = "Hormone Therapy"
    case targetedTherapy    = "Targeted Therapy"
    case surgery            = "Surgery"
    case stemCellTransplant = "Stem Cell Transplant"
}

enum PhaseState {
    case editing
    case saved
}

struct TreatmentPhaseModel {
    var treatmentType: TreatmentType = .none
    var startDate: Date? = nil
    var duration: String = ""
    var state: PhaseState = .editing
}

struct TreatmentModel {
    var phases: [TreatmentPhaseModel] = []
    var status: String = "Not Started"
}
