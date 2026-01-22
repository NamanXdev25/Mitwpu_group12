import Foundation
import UIKit

class UserProfileDataSource {

    static let shared = UserProfileDataSource()
    private(set) var userProfile: ProfileUserProfile
    private let userProfileKey = "savedUserProfile"
    static let profileDidUpdateNotification = Notification.Name("UserProfileDidUpdate")

    private init() {
        if let savedProfile = UserProfileDataSource.loadFromUserDefaults() {
            self.userProfile = savedProfile
            print(" Loaded profile from UserDefaults")
        } else if let defaultProfile = UserProfileDataSource.loadFromJSON() {
            self.userProfile = defaultProfile
            print(" Loaded profile from JSON")
        } else {
            self.userProfile = ProfileUserProfile()
            print(" Using hardcoded default profile")
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

    // MARK: - Persistence

    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(userProfile)
            UserDefaults.standard.set(data, forKey: userProfileKey)
            print(" Profile saved to UserDefaults")
        } catch {
            print(" Failed to save profile: \(error)")
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
            print(" Failed to load profile from UserDefaults: \(error)")
            return nil
        }
    }

    private static func loadFromJSON() -> ProfileUserProfile? {
        guard let url = Bundle.main.url(forResource: "defaultUser", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print(" Could not find defaultUser.json")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ProfileUserProfile.self, from: data)
        } catch {
            print(" Failed to decode JSON: \(error)")
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
