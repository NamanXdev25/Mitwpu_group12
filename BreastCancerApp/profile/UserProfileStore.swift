
import UIKit

class UserProfileStore {

    static let shared = UserProfileStore()
    private init() {}

    static let profileDidChangeNotification = Notification.Name("UserProfileDidChange")

    var profile: HealthProfileModel {
        HealthProfileModel(from: UserProfileDataSource.shared.userProfile)
    }

    func save(_ updated: HealthProfileModel) {
        UserProfileDataSource.shared.updateBasicInfo(
            firstName:    updated.firstName,
            lastName:     updated.lastName,
            profileImage: updated.profileImage
        )

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
