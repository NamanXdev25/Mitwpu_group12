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
            self.userProfile = savedProfile
            print("Loaded profile from repository")
        } else if let defaultProfile = UserProfileDataSource.loadFromJSON() {
            self.userProfile = defaultProfile
            repository.saveProfile(defaultProfile)
            print("Loaded profile from JSON")
        } else {
            self.userProfile = ProfileUserProfile(profileImageBase64: nil)
            repository.saveProfile(self.userProfile)
            print("Using hardcoded default profile")
        }
    }

    // MARK: - Update Profile

    func updateProfile(_ profile: ProfileUserProfile) {
        self.userProfile = profile
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
        
        // Extract first and last name from userName
        let nameParts = onboardingData.userName.split(separator: " ")
        let firstName = nameParts.first.map(String.init) ?? "User"
        let lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
        
        // Update profile with onboarding data
        userProfile.firstName = firstName
        userProfile.lastName = lastName
        
        // Medical information - handle different treatment paths
        let treatmentStatus = onboardingData.treatmentStatus ?? ""
        
        switch treatmentStatus {
        case "Currently in treatment":
            // Full data available
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
            // Limited data
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32 // default
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Observation"
            userProfile.treatmentCompletionDate = ""
            
        case "Post-treatment / in recovery":
            // Completion date and interests
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32 // default
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Completed"
            
            if let completionDate = onboardingData.treatmentCompletionDate {
                userProfile.treatmentCompletionDate = onboardingData.formatDateForProfile(completionDate)
            } else {
                userProfile.treatmentCompletionDate = "NA"
            }
            
        case "Prefer not to say":
            // Minimal data
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32 // default
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Not Specified"
            userProfile.treatmentCompletionDate = ""
            
        default:
            // Unknown status
            userProfile.diagnosisDate = "NA"
            userProfile.age = 32
            userProfile.cancerStage = "NA"
            userProfile.treatmentState = "Unknown"
            userProfile.treatmentCompletionDate = ""
        }
        
        // Save and notify
        persistProfile()
        notifyProfileUpdate()
        
        print("✅ Profile updated from onboarding:")
        print("Name: \(userProfile.fullName)")
        print("Treatment Status: \(treatmentStatus)")
        print("Age: \(userProfile.age)")
        print("Stage: \(userProfile.cancerStage)")
        print("Treatment State: \(userProfile.treatmentState)")
        print("Diagnosis: \(userProfile.diagnosisDate)")
        print("Completion: \(userProfile.treatmentCompletionDate)")
    }

    // MARK: - Persistence

    private func persistProfile() {
        repository.saveProfile(userProfile)
        print("Profile saved to repository")
    }

    private static func loadFromJSON() -> ProfileUserProfile? {
        guard let url = Bundle.main.url(forResource: "defaultUser", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not find defaultUser.json")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ProfileUserProfile.self, from: data)
        } catch {
            print("Failed to decode JSON: \(error)")
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
                  let data = Data(base64Encoded: base64) else {
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
