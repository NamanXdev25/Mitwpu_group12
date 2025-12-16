//
//  MindfulnessDataLoader.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 15/12/25.
//

import Foundation

class MindfulnessDataLoader {
    static let shared = MindfulnessDataLoader()
    private(set) var root: MindfulnessJSONRoot?

    private init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "moodSuggestion", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Mindfulness JSON not found")
            return
        }

        do {
            let dec = JSONDecoder()
            root = try dec.decode(MindfulnessJSONRoot.self, from: data)
        } catch {
            print("JSON decode error:", error)
        }
    }

    func moodContent(for moodKey: String) -> MoodContent? {
        return root?.moods[moodKey]
    }
}
