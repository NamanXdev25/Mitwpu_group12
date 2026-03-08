//
//  UserProfile.swift
//  BreastCancerApp
//
//  Created by Shloka on 07/03/26.
//
//
//  UserProfile.swift
//  BreastCancerApp
//

import UIKit

struct UserProfile {

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

extension UserProfile {

    static var mock: UserProfile {
        return UserProfile(
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
