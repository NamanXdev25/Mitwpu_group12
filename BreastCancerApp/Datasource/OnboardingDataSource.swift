//
//  OnboardingDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import Foundation

struct OnboardingDataSource {
    
    // Treatment Options
    static let treatmentOptions = [
        "Currently in treatment",
        "Under Observation",
        "Post-treatment / in recovery",
        "Prefer not to say"
    ]
    
    // Hobbies
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
    
    // Cancer Stages
    static let cancerStages = [
        "Stage 0",
        "Stage I",
        "Stage II",
        "Stage III",
        "Stage IV",
        "Not sure"
    ]
    
    // Age Groups
    static let ageGroups = [
        "Below 18",
        "18-25",
        "26-35",
        "36-45",
        "46-55",
        "56-65",
        "66-75",
        "75+"
    ]
    
    // Follow-up Frequency
    static let followUpFrequencies = [
        "Every month",
        "Every 2 months",
        "Every 3 months",
        "Every 6 months",
        "Once a year"
    ]
    
    // Post Treatment Focus
    static let postTreatmentInterests = [
        InterestOption(title: "Physical Strength", icon: "figure.strengthtraining.traditional"),
        InterestOption(title: "Mindfulness", icon: "figure.mind.and.body")
    ]
    
    // Prefer Not To Say Interests
    static let preferNotToSayInterests = [
        InterestOption(title: "Physical Strength", icon: "figure.strengthtraining.traditional.circle.fill"),
        InterestOption(title: "Mindfulness", icon: "figure.mind.and.body.circle.fill"),
        InterestOption(title: "Prevention", icon: "magnifyingglass.circle.fill"),
        InterestOption(title: "Learning", icon: "book.circle.fill")
    ]
}

// Interest Option Model
struct InterestOption {
    let title: String
    let icon: String
}
