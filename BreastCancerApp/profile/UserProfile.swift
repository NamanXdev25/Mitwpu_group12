
import UIKit

struct HealthProfileModel {
    var firstName: String
    var lastName: String
    var diagnosisDate: Date
    var gender: Gender
    var dateOfBirth: Date
    var treatmentPhase: TreatmentPhase
    var profileImage: UIImage?
}

enum Gender: String, CaseIterable {
    case male           = "Male"
    case female         = "Female"
    case preferNotToSay = "Prefer not to say"
}

enum TreatmentPhase: String, CaseIterable {
    case recentlyDiagnosed = "Recently Diagnosed"
    case chemotherapy      = "Chemotherapy"
    case surgery           = "Surgery"
    case radiationTherapy  = "Radiation Therapy"
    case hormoneTherapy    = "Hormone Therapy"
}

// MARK: - Bridge from main app's ProfileUserProfile
extension HealthProfileModel {

    init(from profile: ProfileUserProfile) {
        self.firstName    = profile.firstName
        self.lastName     = profile.lastName
        self.profileImage = profile.profileImage

        self.gender = Gender(rawValue: profile.gender) ?? .female

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        self.diagnosisDate = formatter.date(from: profile.diagnosisDate)
            ?? Calendar.current.date(byAdding: .year, value: -1, to: Date())
            ?? Date()

        self.dateOfBirth = Calendar.current.date(
            byAdding: .year, value: -profile.age, to: Date()
        ) ?? Date()

        let phaseName = JourneyState.shared.currentTreatmentName
        self.treatmentPhase = TreatmentPhase(rawValue: phaseName) ?? .recentlyDiagnosed
    }
}

// MARK: - Mock for previews / testing only
extension HealthProfileModel {
    static var mock: HealthProfileModel {
        HealthProfileModel(
            firstName:      "Sophie",
            lastName:       "Chen",
            diagnosisDate:  Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 1)) ?? Date(),
            gender:         .female,
            dateOfBirth:    Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15)) ?? Date(),
            treatmentPhase: .chemotherapy,
            profileImage:   nil
        )
    }
}
