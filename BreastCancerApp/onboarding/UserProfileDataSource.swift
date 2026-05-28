import Foundation
import UIKit

class UserProfileDataSource {
    static let shared = UserProfileDataSource()
    private(set) var userProfile: ProfileUserProfile
    private let repository: ProfileRepository
    static let profileDidUpdateNotification = Notification.Name("UserProfileDidUpdate")

    private init(repository: ProfileRepository = RepositoryFactory.makeProfileRepository()) {
        self.repository = repository

        if let savedProfile = repository.loadProfile() {
            userProfile = savedProfile
        } else if let defaultProfile = UserProfileDataSource.loadFromJSON() {
            userProfile = defaultProfile
            repository.saveProfile(defaultProfile)
        } else {
            userProfile = ProfileUserProfile(profileImageBase64: nil)
            repository.saveProfile(userProfile)
        }
    }

    // MARK: - Update Profile

    func updateProfile(_ profile: ProfileUserProfile) {
        userProfile = profile
        persistProfile()
        notifyProfileUpdate()
    }

    func updateBasicInfo(
        firstName: String,
        lastName: String,
        profileImage: UIImage?
    ) {
        userProfile.firstName = firstName
        userProfile.lastName = lastName
        userProfile.profileImage = profileImage
        persistProfile()
        notifyProfileUpdate()
    }

    func updateMedicalInfo(
        diagnosisDate: String? = nil,
        gender: String? = nil,
        age: Int? = nil,
        cancerStage: String? = nil,
        treatmentState: String? = nil,
        treatmentCompletionDate: String? = nil
    ) {
        if let diagnosisDate = diagnosisDate {
            userProfile.diagnosisDate = diagnosisDate
        }
        if let gender = gender {
            userProfile.gender = gender
        }
        if let age = age {
            userProfile.age = age
        }
        if let cancerStage = cancerStage {
            userProfile.cancerStage = cancerStage
        }
        if let treatmentState = treatmentState {
            userProfile.treatmentState = treatmentState
        }
        if let treatmentCompletionDate = treatmentCompletionDate {
            userProfile.treatmentCompletionDate = treatmentCompletionDate
        }

        persistProfile()
        notifyProfileUpdate()
    }

    // MARK: - Notification Settings

    func updateNotificationSettings(
        exercise: Bool? = nil,
        hydration: Bool? = nil,
        appointments: Bool? = nil,
        medications: Bool? = nil
    ) {
        if let exercise = exercise {
            userProfile.exerciseNotificationsEnabled = exercise
        }
        if let hydration = hydration {
            userProfile.hydrationNotificationsEnabled = hydration
        }
        if let appointments = appointments {
            userProfile.appointmentsNotificationsEnabled = appointments
        }
        if let medications = medications {
            userProfile.medicationsNotificationsEnabled = medications
        }
        persistProfile()
        notifyProfileUpdate()
    }

    func transferFromOnboarding() {
        let onboardingData = OnboardingData.shared

        let nameParts = onboardingData.userName.split(separator: " ")
        let firstName = nameParts.first.map(String.init) ?? "User"
        let lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""

        userProfile.firstName = firstName
        userProfile.lastName = lastName

        let treatmentStatus = onboardingData.treatmentStatus ?? ""

        switch treatmentStatus {
        case "Currently in treatment":
            if let diagnosisDate = onboardingData.diagnosisDate {
                userProfile.diagnosisDate = onboardingData.formatDateForProfile(diagnosisDate)
            } else {
                userProfile.diagnosisDate = "NA"
            }

            userProfile.age = onboardingData.getApproximateAge()
            userProfile.cancerStage = onboardingData.currentStage ?? "NA"
            userProfile.treatmentState = "Ongoing"
            userProfile.treatmentCompletionDate = ""

        case "Under Observation":
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Observation"
            userProfile.treatmentCompletionDate = ""

        case "Post-treatment / in recovery":
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Completed"

            if let completionDate = onboardingData.treatmentCompletionDate {
                userProfile.treatmentCompletionDate = onboardingData.formatDateForProfile(completionDate)
            } else {
                userProfile.treatmentCompletionDate = "NA"
            }

        case "Prefer not to say":
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Not Specified"
            userProfile.treatmentCompletionDate = ""

        default:
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Unknown"
            userProfile.treatmentCompletionDate = ""
        }

        persistProfile()
        notifyProfileUpdate()
    }

    // MARK: - Persistence

    private func persistProfile() {
        repository.saveProfile(userProfile)
    }

    private static func loadFromJSON() -> ProfileUserProfile? {
        guard let url = Bundle.main.url(forResource: "defaultUser", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ProfileUserProfile.self, from: data)
        } catch {
            return nil
        }
    }

    private func notifyProfileUpdate() {
        NotificationCenter.default.post(
            name: UserProfileDataSource.profileDidUpdateNotification,
            object: self,
            userInfo: ["profile": userProfile]
        )
    }
}

extension ProfileUserProfile {
    var profileImage: UIImage? {
        get {
            guard let base64 = profileImageBase64,
                  let data = Data(base64Encoded: base64)
            else {
                return nil
            }
            return UIImage(data: data)
        }
        set {
            if let image = newValue,
               let data = image.jpegData(compressionQuality: 0.8) {
                profileImageBase64 = data.base64EncodedString()
            } else {
                profileImageBase64 = nil
            }
        }
    }

    init(
        firstName: String,
        lastName: String,
        profileImage: UIImage? = nil,
        diagnosisDate: String = "12 Aug 2024",
        gender: String = "Female",
        age: Int = 32,
        cancerStage: String = "Stage II",
        treatmentState: String = "Ongoing",
        treatmentCompletionDate: String = "",
        exerciseNotificationsEnabled: Bool = false,
        hydrationNotificationsEnabled: Bool = false,
        appointmentsNotificationsEnabled: Bool = false,
        medicationsNotificationsEnabled: Bool = false
    ) {
        self.init(
            firstName: firstName,
            lastName: lastName,
            profileImageBase64: nil,
            diagnosisDate: diagnosisDate,
            gender: gender,
            age: age,
            cancerStage: cancerStage,
            treatmentState: treatmentState,
            treatmentCompletionDate: treatmentCompletionDate,
            exerciseNotificationsEnabled: exerciseNotificationsEnabled,
            hydrationNotificationsEnabled: hydrationNotificationsEnabled,
            appointmentsNotificationsEnabled: appointmentsNotificationsEnabled,
            medicationsNotificationsEnabled: medicationsNotificationsEnabled
        )
        self.profileImage = profileImage
    }
}
