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
        userName = "User"
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
    
    // MARK: - Helper Methods for Profile Transfer
    
    /// Converts the current age string (e.g., "26-35") to an approximate integer age
    func getApproximateAge() -> Int {
        guard let ageRange = currentAge else { return 32 } // default
        
        // Parse age range strings like "26-35", "18-25", etc.
        if ageRange.contains("-") {
            let components = ageRange.split(separator: "-")
            if components.count == 2,
               let lowerBound = Int(components[0]),
               let upperBound = Int(components[1]) {
                // Return the midpoint of the range
                return (lowerBound + upperBound) / 2
            }
        }
        
        // Handle special cases
        if ageRange.lowercased().contains("below 18") {
            return 16
        }
        if ageRange.contains("75+") {
            return 77
        }
        
        return 32 // fallback default
    }
    
    /// Formats a Date to the profile's expected string format
    func formatDateForProfile(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    /// Determines the treatment state based on onboarding selection
    func getTreatmentState() -> String {
        guard let status = treatmentStatus else { return "Unknown" }
        
        switch status {
        case "Currently in treatment":
            return "Ongoing"
        case "Under Observation":
            return "Observation"
        case "Post-treatment / in recovery":
            return "Completed"
        case "Prefer not to say":
            return "Not Specified"
        default:
            return "Unknown"
        }
    }
}
