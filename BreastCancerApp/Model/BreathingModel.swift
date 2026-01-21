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
    let videoFileName: String
}

class BreathingDataManager {
    
    func getFavoriteSessions() -> [BreathingSession] {
        return []
    }
    
    func getFilterTags() -> [String] {
        return ["All", "Meditation", "Stress Relief", "Sleep", "Wellness", "Gratitude"]
    }
    
    func getAllSessions() -> [BreathingSession] {
        return [
            BreathingSession(title: "Gentle Focus", category: "Meditation", duration: "15 min", imageName: "gentle_focus", isFavorite: false, videoFileName: "breathingsesh"),
            
            BreathingSession(title: "Healing Reflections", category: "Gratitude", duration: "12 min", imageName: "healing_reflections", isFavorite: false, videoFileName: "healing_video"),
            
            BreathingSession(title: "Calmer Mind", category: "Stress Relief", duration: "8 min", imageName: "calmer_mind", isFavorite: false, videoFileName: "calm_video"),
            
            BreathingSession(title: "Inner Calm", category: "Meditation", duration: "10 min", imageName: "inner_calm", isFavorite: false, videoFileName: "inner_video"),
            
            BreathingSession(title: "Gentle Recharge", category: "Stress Relief", duration: "10 min", imageName: "gentle_recharge", isFavorite: false, videoFileName: "recharge_video"),
            
            BreathingSession(title: "Nausea Relief", category: "Wellness", duration: "5 min", imageName: "nausea_relief", isFavorite: false, videoFileName: "nausea_video"),
            
            BreathingSession(title: "Morning Appreciation", category: "Gratitude", duration: "5 min", imageName: "morning_appreciation", isFavorite: false, videoFileName: "morning_video"),
            
            BreathingSession(title: "Deep Rest", category: "Sleep", duration: "15 min", imageName: "deep_rest", isFavorite: false, videoFileName: "sleep_video")
        ]
    }
}
