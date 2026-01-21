//
//  UserProfileDataSource.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 21/01/26.
//
import Foundation
import UIKit

class UserProfileDataSource {
    
    static let shared = UserProfileDataSource()
    private(set) var userProfile: UserProfile
    private let userProfileKey = "savedUserProfile"
    static let profileDidUpdateNotification = Notification.Name("UserProfileDidUpdate")
    
    private init() {
        // Try to load saved profile, otherwise load from JSON
        if let savedProfile = UserProfileDataSource.loadFromUserDefaults() {
            self.userProfile = savedProfile
            print(" Loaded profile from UserDefaults")
        } else if let defaultProfile = UserProfileDataSource.loadFromJSON() {
            self.userProfile = defaultProfile
            print(" Loaded profile from JSON")
        } else {
            // Fallback to hardcoded default
            self.userProfile = UserProfile()
            print(" Using hardcoded default profile")
        }
    }

    
    // update the entire user profile
    func updateProfile(_ profile: UserProfile) {
        self.userProfile = profile
        saveToUserDefaults()
        notifyProfileUpdate()
    }
    
    // update specific fields
    func updateBasicInfo(firstName: String, lastName: String, profileImage: UIImage?) {
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
        treatmentState: String? = nil
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
        saveToUserDefaults()
        notifyProfileUpdate()
    }
    
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
    
    // reset to default profile from JSON
    func resetToDefault() {
        if let defaultProfile = UserProfileDataSource.loadFromJSON() {
            self.userProfile = defaultProfile
            saveToUserDefaults()
            notifyProfileUpdate()
            print(" Profile reset to default")
        }
    }
    
    // clear all saved data
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: userProfileKey)
        if let defaultProfile = UserProfileDataSource.loadFromJSON() {
            self.userProfile = defaultProfile
        } else {
            self.userProfile = UserProfile()
        }
        notifyProfileUpdate()
        print(" All data cleared")
    }
    
    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(userProfile)
            UserDefaults.standard.set(data, forKey: userProfileKey)
            print("Profile saved to UserDefaults")
        } catch {
            print(" Failed to save profile: \(error)")
        }
    }
    
    private static func loadFromUserDefaults() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "savedUserProfile") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let profile = try decoder.decode(UserProfile.self, from: data)
            return profile
        } catch {
            print(" Failed to load profile from UserDefaults: \(error)")
            return nil
        }
    }
    
    private static func loadFromJSON() -> UserProfile? {
        guard let url = Bundle.main.url(forResource: "defaultUser", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print(" Could not find defaultUser.json")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let profile = try decoder.decode(UserProfile.self, from: data)
            return profile
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
