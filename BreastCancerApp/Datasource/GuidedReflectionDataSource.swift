//
//  GuidedReflectionDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 27/11/25.
//

import Foundation

#if canImport(JournalingSuggestions)
import JournalingSuggestions
#endif

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
    
    // MARK: - Enhanced Today's Question with Apple Suggestions
    
    func getTodaysQuestion(completion: @escaping (GuidedReflectionQuestion?) -> Void) {
        let defaults = UserDefaults.standard
        let today = currentDateString()

        // Check if we already have today's question cached
        if let savedDate = defaults.string(forKey: "todaysReflectionDate"),
           savedDate == today,
           let savedID = defaults.string(forKey: "todaysReflectionID") {
            
            // Check if it's an Apple suggestion
            if let savedSuggestionID = defaults.string(forKey: "todaysAppleSuggestionID") {
                fetchAppleSuggestion(withID: savedSuggestionID) { suggestion in
                    if let suggestion = suggestion {
                        completion(suggestion)
                    } else {
                        // Fallback to JSON question if Apple suggestion is no longer available
                        if let question = self.questions.first(where: { $0.id.uuidString == savedID }) {
                            completion(question)
                        } else {
                            completion(self.questions.randomElement())
                        }
                    }
                }
                return
            }
            
            if let question = questions.first(where: { $0.id.uuidString == savedID }) {
                completion(question)
                return
            }
        }

        if #available(iOS 17.2, *) {
            fetchTodaysQuestionWithSuggestions { question in
                completion(question)
            }
        } else {
            // Fallback for older iOS versions
            let question = self.getRandomJSONQuestion()
            self.cacheTodaysQuestion(question, isAppleSuggestion: false)
            completion(question)
        }
    }
    
    // MARK: - Apple JournalingSuggestions Integration
    
    @available(iOS 17.2, *)
    private func fetchTodaysQuestionWithSuggestions(completion: @escaping (GuidedReflectionQuestion?) -> Void) {
        let question = self.getRandomJSONQuestion()
        self.cacheTodaysQuestion(question, isAppleSuggestion: false)
        completion(question)
    }
    
    @available(iOS 17.2, *)
    private func fetchAppleSuggestion(withID id: String, completion: @escaping (GuidedReflectionQuestion?) -> Void) {
        completion(nil)
    }
    
    // MARK: - Helper Methods
    
    private func getRandomJSONQuestion() -> GuidedReflectionQuestion {
        return questions.randomElement() ?? questions[0]
    }
    
    private func cacheTodaysQuestion(_ question: GuidedReflectionQuestion, isAppleSuggestion: Bool, suggestionID: String? = nil) {
        let defaults = UserDefaults.standard
        let today = currentDateString()
        
        defaults.set(today, forKey: "todaysReflectionDate")
        defaults.set(question.id.uuidString, forKey: "todaysReflectionID")
        
        if isAppleSuggestion, let suggestionID = suggestionID {
            defaults.set(suggestionID, forKey: "todaysAppleSuggestionID")
        } else {
            defaults.removeObject(forKey: "todaysAppleSuggestionID")
        }
    }

    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Permission Request
    
    @available(iOS 17.2, *)
    func requestSuggestionsPermission() {
        // Permission is requested automatically when fetching suggestions
    }
}
