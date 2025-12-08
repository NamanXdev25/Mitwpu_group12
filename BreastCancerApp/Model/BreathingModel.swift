//
//  BreathingModel.swift
//  BreastCancerApp
//
//  Created by Shloka on 28/11/25.
//

import Foundation
import UIKit


struct BreathingSession {
    let title: String
    let category: String
    let duration: String
    let imageName: String
    var isFavorite: Bool
}

class BreathingDataManager {
    
    // SECTION 0: Start empty!
    func getFavoriteSessions() -> [BreathingSession] {
        return []
    }
    
    // SECTION 1: Filter Tags (Keep as is)
    func getFilterTags() -> [String] {
        return ["All", "Meditation", "Stress Relief", "Sleep", "Wellness", "Gratitude"]
    }
    
    // SECTION 2: Vertical List
    func getAllSessions() -> [BreathingSession] {
        return [
            BreathingSession(title: "Gentle Focus", category: "Meditation", duration: "15 min", imageName: "gentle_focus", isFavorite: false),
            BreathingSession(title: "Healing Reflections", category: "Gratitude", duration: "12 min", imageName: "healing_reflections", isFavorite: false),
            BreathingSession(title: "Calmer Mind", category: "Stress Relief", duration: "8 min", imageName: "calmer_mind", isFavorite: false),
            BreathingSession(title: "Inner Calm", category: "Meditation", duration: "10 min", imageName: "inner_calm", isFavorite: false),
            BreathingSession(title: "Gentle Recharge", category: "Stress Relief", duration: "10 min", imageName: "gentle_recharge", isFavorite: false),
            BreathingSession(title: "Nausea Relief", category: "Wellness", duration: "5 min", imageName: "nausea_relief", isFavorite: false),
            BreathingSession(title: "Morning Appreciation", category: "Gratitude", duration: "5 min", imageName: "morning_appreciation", isFavorite: false),
            BreathingSession(title: "Deep Rest", category: "Sleep", duration: "15 min", imageName: "calm_drift", isFavorite: false)
        ]
    }
}
