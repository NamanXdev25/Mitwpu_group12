//
//  OnboardingData.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import Foundation

class OnboardingData {
    
    // Singleton instance
    static let shared = OnboardingData()
    
    // User's selections
    var treatmentStatus: String?
    var selectedHobbies: [String] = []
    var userName: String = "Sophie" // Default name, can be changed
    
    // currently in treatment
    var diagnosisDate: Date?
    var currentAge: String?
    var currentStage: String?
    
    // under observation
    var lastCheckupDate: Date?
    var followUpFrequency: String?
    
    // post treatment
    var treatmentCompletionDate: Date?
    var selectedInterests: [String] = []
    
    private init() {}
    
    // Reset all data
    func reset() {
        treatmentStatus = nil
        diagnosisDate = nil
        currentAge = nil
        currentStage = nil
        selectedHobbies.removeAll()
        lastCheckupDate = nil
        followUpFrequency = nil
        treatmentCompletionDate = nil
        selectedInterests.removeAll()
    }
    
    // Check if onboarding is complete
    func isComplete() -> Bool {
        return treatmentStatus != nil &&
               diagnosisDate != nil &&
               currentAge != nil &&
               currentStage != nil &&
               !selectedHobbies.isEmpty
    }
}
