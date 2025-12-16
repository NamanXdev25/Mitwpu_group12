//
//  MindfulnessSlide.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/12/25.
//

struct MindfulnessSlide {
    let title: String
    let description: String
    let buttonText: String
    let action: SlideAction
    let destination: SlideDestination?
}

enum SlideAction {
    case next
    case begin
    case addPhoto
}

enum SlideDestination {
    case breathing(sessionID: String)
    case journalBlank
}
