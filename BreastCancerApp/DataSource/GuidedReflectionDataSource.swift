//
//  GuidedReflectionDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 27/11/25.
//

import Foundation

class GuidedReflectionDataSource {
    static let shared = GuidedReflectionDataSource()

    private(set) var questions: [GuidedReflectionQuestion] = []

    private init() {
        loadQuestions()
    }

    private func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "GuidedReflectionData", withExtension: "json") else {
            print("Failed to load JSON")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            questions = try JSONDecoder().decode([GuidedReflectionQuestion].self, from: data)
        } catch {
            print("JSON parsing error:", error)
        }
    }

    func getQuestions(for category: ReflectionCategory) -> [GuidedReflectionQuestion] {
        questions.filter { $0.category == category }
    }

    func getRandomQuestion(for category: ReflectionCategory) -> GuidedReflectionQuestion? {
        getQuestions(for: category).randomElement()
    }
    
    func getTodaysQuestion() -> GuidedReflectionQuestion? {
        let defaults = UserDefaults.standard
        
        // 1. Check if we already stored today's question
        if let savedID = defaults.string(forKey: "todaysReflectionID"),
           let question = questions.first(where: { $0.id.uuidString == savedID }) {
            return question
        }
        
        // 2. Otherwise pick a new one
        guard let random = questions.randomElement() else { return nil }
        
        // 3. Save today's date + question ID
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        defaults.set(today, forKey: "todaysReflectionDate")
        defaults.set(random.id.uuidString, forKey: "todaysReflectionID")
        
        return random
    }
    
    func refreshIfNeeded() {
        let defaults = UserDefaults.standard

        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let savedDate = defaults.string(forKey: "todaysReflectionDate")

        if savedDate != today {
            defaults.removeObject(forKey: "todaysReflectionID")
            defaults.set(today, forKey: "todaysReflectionDate")
        }
    }


}
