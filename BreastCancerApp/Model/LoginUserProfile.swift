//
//  UserProfile.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 20/01/26.
//

import Foundation

// User Profile model
struct UserProfile {
    let id: String
    let name: String
    let email: String
    let password: String
    let treatmentStatus: String
    let hobbies: [String]
    let profileImageName: String?

    let diagnosisDate: Date?
    let currentAge: String?
    let currentStage: String?

    let lastCheckupDate: Date?
    let followUpFrequency: String?

    let treatmentCompletionDate: Date?
    let interests: [String]?
}

// healing garden stats
struct HealingGardenStats {
    var currentPoints: Int
    var totalPointsNeeded: Int
    var currentLevel: Int
    var nextLevel: Int
    
    var pointsToNextLevel: Int {
        return totalPointsNeeded - currentPoints
    }
    
    var progress: Float {
        return Float(currentPoints) / Float(totalPointsNeeded)
    }
}
