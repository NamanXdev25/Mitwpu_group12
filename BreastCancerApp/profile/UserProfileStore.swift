//
//  UserProfileStore.swift
//  BreastCancerApp
//

import UIKit

// Bridges the Profile feature's HealthProfileModel to UserProfileDataSource (single source of truth).
class UserProfileStore {

    static let shared = UserProfileStore()
    private init() {}

    static let profileDidChangeNotification = Notification.Name("UserProfileDidChange")

    // Always reads live from the main app store — never stale
    var profile: HealthProfileModel {
        HealthProfileModel(from: UserProfileDataSource.shared.userProfile)
    }

    func save(_ updated: HealthProfileModel) {
        // Write name + image back to main store
        UserProfileDataSource.shared.updateBasicInfo(
            firstName:    updated.firstName,
            lastName:     updated.lastName,
            profileImage: updated.profileImage
        )

        // Write medical fields back to main store
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let diagnosisString = formatter.string(from: updated.diagnosisDate)

        let age = Calendar.current.dateComponents(
            [.year], from: updated.dateOfBirth, to: Date()
        ).year ?? UserProfileDataSource.shared.userProfile.age

        UserProfileDataSource.shared.updateMedicalInfo(
            diagnosisDate:  diagnosisString,
            gender:         updated.gender.rawValue,
            age:            age,
            treatmentState: updated.treatmentPhase.rawValue
        )

        NotificationCenter.default.post(name: Self.profileDidChangeNotification, object: nil)
    }
}
