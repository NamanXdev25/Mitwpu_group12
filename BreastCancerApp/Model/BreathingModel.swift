//
//  BreathingModel.swift
//  BreastCancerApp
//
//  Created by Shloka on 28/11/25.
//

import Foundation
import UIKit

// 1. The Blueprint for a single session
struct BreathingSession {
    let title: String       // e.g., "Calmer Mind"
    let category: String    // e.g., "Stress Relief"
    let duration: String    // e.g., "8 min"
    let imageName: String   // Name of image in Assets
    let isFavorite: Bool    // For the heart icon
}

// 2. The Data Manager (Acts like your 'DestinationsResponse')
class BreathingDataManager {
    
    // SECTION 0: Get the big cards for "Favourites"
    func getFavoriteSessions() -> [BreathingSession] {
        return [
            BreathingSession(title: "Calmer Mind", category: "Stress Relief", duration: "8 min", imageName: "img_calm", isFavorite: true),
            BreathingSession(title: "Morning Appreciation", category: "Gratitude", duration: "5 min", imageName: "img_morning", isFavorite: true),
            BreathingSession(title: "Deep Rest", category: "Sleep", duration: "15 min", imageName: "img_sleep", isFavorite: true)
        ]
    }
    
    // SECTION 1: Get the Filter Tags
    func getFilterTags() -> [String] {
        return ["All", "Meditation", "Stress Relief", "Sleep", "Wellness", "Gratitude"]
    }
    
    // SECTION 2: Get the vertical list of sessions
    func getAllSessions() -> [BreathingSession] {
        return [
            BreathingSession(title: "Gentle Focus", category: "Meditation", duration: "15 min", imageName: "img_focus", isFavorite: false),
            BreathingSession(title: "Healing Reflections", category: "Gratitude", duration: "12 min", imageName: "img_healing", isFavorite: false),
            BreathingSession(title: "Calmer Mind", category: "Stress Relief", duration: "8 min", imageName: "img_calm", isFavorite: true),
            BreathingSession(title: "Inner Calm", category: "Meditation", duration: "10 min", imageName: "img_inner", isFavorite: true),
            BreathingSession(title: "Gentle Recharge", category: "Stress Relief", duration: "10 min", imageName: "img_recharge", isFavorite: false),
            BreathingSession(title: "Nausea Relief", category: "Wellness", duration: "5 min", imageName: "img_nausea", isFavorite: false)
        ]
    }
}
