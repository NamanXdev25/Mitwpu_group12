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
        let today = currentDateString()

        if let savedDate = defaults.string(forKey: "todaysReflectionDate"),
           savedDate == today,
           let savedID = defaults.string(forKey: "todaysReflectionID"),
           let question = questions.first(where: { $0.id.uuidString == savedID }) {
            return question
        }

        guard let random = questions.randomElement() else { return nil }

        defaults.set(today, forKey: "todaysReflectionDate")
        defaults.set(random.id.uuidString, forKey: "todaysReflectionID")

        return random
    }

    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
