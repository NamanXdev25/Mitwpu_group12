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
}

enum ReflectionCategory: String, Codable, CaseIterable {
    case mindfulness
    case gratitude
    case anxiety
    case positivity
    case healing
    case selfCompassion = "self_compassion"
}
