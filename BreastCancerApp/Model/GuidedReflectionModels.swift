//
//  GuidedReflectionModels.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 27/11/25.
//

import Foundation

struct GuidedReflectionQuestion: Identifiable, Codable {
    let id: UUID
    let category: ReflectionCategory
    let question: String
    let tags: [String]?
    var appleSuggestionID: String? // Added for Apple suggestions
    
    // Custom init for Apple suggestions
    init(id: UUID = UUID(),
         category: ReflectionCategory,
         question: String,
         tags: [String]? = nil,
         appleSuggestionID: String? = nil) {
        self.id = id
        self.category = category
        self.question = question
        self.tags = tags
        self.appleSuggestionID = appleSuggestionID
    }
}

enum ReflectionCategory: String, Codable, CaseIterable {
    case mindfulness
    case gratitude
    case anxiety
    case positivity
    case healing
    case selfCompassion = "self_compassion"
}
