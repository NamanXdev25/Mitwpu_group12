//
//  OnboardingData.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import Foundation

class OnboardingData {
    
    // singleton instance
    static let shared = OnboardingData()
    
    var userName: String = "User" // default name for testing
    var treatmentStatus: String?
    
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
    
    // hobbies
    var selectedHobbies: [String] = []
    
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
