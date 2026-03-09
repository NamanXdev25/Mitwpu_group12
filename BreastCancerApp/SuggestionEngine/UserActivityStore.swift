//
//  UserActivityStore.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/03/26.
//

// Tracks which suggestions the user taps over time.
// Used to boost frequently-engaged items in future suggestions.

import Foundation

final class UserActivityStore {
    static let shared = UserActivityStore()
    private init() { load() }

    private let key = "uas_tapCounts"
    private var tapCounts: [String: Int] = [:]

    // MARK: - Recording taps

    func recordBreathingTap(title: String) {
        increment(key: "b:" + normalized(title))
    }

    func recordHobbyTap(title: String) {
        increment(key: "h:" + normalized(title))
    }

    // MARK: - Reading weights (returns 1, 2, or 3)

    func breathingWeight(for title: String) -> Int {
        weight(for: "b:" + normalized(title))
    }

    func hobbyWeight(for title: String) -> Int {
        weight(for: "h:" + normalized(title))
    }

    // MARK: - Top hobbies by engagement (for default state)

    func topHobbies(limit: Int = 3) -> [String] {
        tapCounts
            .filter { $0.key.hasPrefix("h:") }
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { String($0.key.dropFirst(2)) }  // strip "h:" prefix
    }

    // MARK: - Helpers

    private func increment(key k: String) {
        tapCounts[k, default: 0] += 1
        save()
    }

    private func weight(for k: String) -> Int {
        switch tapCounts[k] ?? 0 {
        case 0:      return 1
        case 1...2:  return 2
        default:     return 3
        }
    }

    private func normalized(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func save() {
        UserDefaults.standard.set(tapCounts, forKey: key)
    }

    private func load() {
        tapCounts = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:]
    }
}
