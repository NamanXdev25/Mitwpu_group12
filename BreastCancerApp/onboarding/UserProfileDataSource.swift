import Foundation
import UIKit

class UserProfileDataSource {

    static let shared = UserProfileDataSource()
    private(set) var userProfile: ProfileUserProfile
    private let userProfileKey = "savedUserProfile"
    static let profileDidUpdateNotification = Notification.Name("UserProfileDidUpdate")

    private init() {
        // First check if there's a saved profile from a previous session
        if let savedProfile = UserProfileDataSource.loadFromUserDefaults() {
            self.userProfile = savedProfile
            print("Loaded profile from UserDefaults")
        } else if let defaultProfile = UserProfileDataSource.loadFromJSON() {
            self.userProfile = defaultProfile
            print("Loaded profile from JSON")
        } else {
            self.userProfile = ProfileUserProfile()
            print("Using hardcoded default profile")
        }
    }

    // MARK: - Update Profile

    func updateProfile(_ profile: ProfileUserProfile) {
        self.userProfile = profile
        saveToUserDefaults()
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
        saveToUserDefaults()
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

        saveToUserDefaults()
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
        saveToUserDefaults()
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
        saveToUserDefaults()
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

    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(userProfile)
            UserDefaults.standard.set(data, forKey: userProfileKey)
            print("Profile saved to UserDefaults")
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    private static func loadFromUserDefaults() -> ProfileUserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "savedUserProfile") else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ProfileUserProfile.self, from: data)
        } catch {
            print("Failed to load profile from UserDefaults: \(error)")
            return nil
        }
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
