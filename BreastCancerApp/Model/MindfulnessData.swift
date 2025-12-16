//
//  MindfulnessData.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 10/12/25.
//

import Foundation

struct MindfulnessJSONRoot: Decodable {
    let moods: [String: MoodContent]
}

struct MoodContent: Decodable {
    let intro: SlideCardJSON
    let breathing: [SlideCardJSON]
    let journaling: [SlideCardJSON]
    let hobby: [SlideCardJSON]
}

struct SlideCardJSON: Decodable {
    let title: String
    let description: String
    let buttonText: String?
}
