//
//  OnboardingDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import Foundation

struct OnboardingDataSource {
    
    // MARK: - Treatment Options
    static let treatmentOptions = [
        "Currently in treatment",
        "Under Observation",
        "Post-treatment / in recovery",
        "Prefer not to say"
    ]
    
    // MARK: - Hobbies
    static let hobbies = [
        "Drawing",
        "music",
        "Painting",
        "Crafting",
        "Reading",
        "Cooking",
        "Watching movies",
        "Meditation",
        "Listening to calming music",
        "Walking",
        "Talking to family",
        "Gardening",
        "Journaling"
    ]
    
    // MARK: - Cancer Stages (for dropdown)
    static let cancerStages = [
        "Stage 0",
        "Stage I",
        "Stage II",
        "Stage III",
        "Stage IV",
        "Not sure"
    ]
    
    // MARK: - Age Groups (for dropdown)
    static let ageGroups = [
        "18-25",
        "26-35",
        "36-45",
        "46-55",
        "56-65",
        "65+"
    ]
}
