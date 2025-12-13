//
//  ExerciseModel.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 26/11/25.
//

import UIKit

// --- 1. DATA STRUCTURES ---

struct PlanItem: Codable {
    var id: String
    var title: String
    var subtitle: String
    var time: String
    var isCompleted: Bool
    var description: String? // --- NEW: Added description field
}

struct ExerciseItem: Codable {
    var title: String
    var category: String
    var imageName: String
}

// --- 2. THE MANAGER ---

class ExerciseManager {
    
    // Singleton - convenient access across controllers
    static let shared = ExerciseManager()
    
    private let todaysPlanStorageKey = "com.yourapp.todaysPlan.v1" // persistence key
    
    var todaysPlan: [PlanItem] = []
    var myExercises: [ExerciseItem] = []
    var exploreItems: [ExerciseItem] = []
    
    init() {
        loadAllData()
        // Try to load saved plan (overrides today's plan loaded from bundle if present)
        loadSavedPlan()
    }
    
    func loadAllData() {
        // Load each file individually using our helper function
        self.todaysPlan = loadJSON(filename: "todaysPlan")
        self.myExercises = loadJSON(filename: "myExercises")
        self.exploreItems = loadJSON(filename: "explore")
    }
    
    // Helper function to load any JSON file into a list
    func loadJSON<T: Codable>(filename: String) -> [T] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Error: Could not find \(filename).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let items = try decoder.decode([T].self, from: data)
            return items
        } catch {
            print("Error parsing \(filename).json: \(error)")
            return []
        }
    }
    
    // MARK: - Plan manipulation (with persistence)
    
    // Logic: Toggle Checkmark
    func togglePlanItem(at index: Int) {
        if index < todaysPlan.count {
            todaysPlan[index].isCompleted.toggle()
            saveTodaysPlan()
        }
    }
    
    // Logic: Add to Plan (from Explore items)
    func addExerciseToPlan(_ exercise: ExerciseItem) {
        let newItem = PlanItem(
            id: UUID().uuidString,
            title: exercise.title,
            subtitle: exercise.category,
            time: "5 min",
            isCompleted: false,
            description: nil // Default nil for generic explore items
        )
        todaysPlan.insert(newItem, at: 0)
        saveTodaysPlan()
    }
    
    func addPlanItem(_ item: PlanItem) {
        // Insert at TOP of the list
        // If item.id already exists, remove old one to avoid duplicates
        if containsExercise(id: item.id) {
            _ = removeExercisesById(item.id)
        }
        todaysPlan.insert(item, at: 0)
        saveTodaysPlan()
    }

    // --- NEW: ID-based Helpers for robust matching ---

    /// Check if an exercise with the given title exists in today's plan (backwards-compatible)
    func containsExercise(title: String) -> Bool {
        return todaysPlan.contains { $0.title == title }
    }

    /// Check if an exercise with the given id exists in today's plan (preferred)
    func containsExercise(id: String) -> Bool {
        return todaysPlan.contains { $0.id == id }
    }

    /// Add a DetailExerciseItem into today's plan, using the detail.id as PlanItem.id
    func addDetailExerciseToPlan(_ detail: DetailExerciseItem) {
        // Use detail.id as the PlanItem.id so we keep the identity across screens.
        let newItem = PlanItem(
            id: detail.id,
            title: detail.title,
            subtitle: detail.subtitle,
            time: detail.time,
            isCompleted: false,
            description: nil // Default nil, can be updated later by editing
        )
        // Avoid duplicates (if same id already exists, remove first)
        if containsExercise(id: detail.id) {
            _ = removeExercisesById(detail.id)
        }
        todaysPlan.insert(newItem, at: 0)
        saveTodaysPlan()
    }

    /// Remove plan items matching the given title. Returns number removed.
    @discardableResult
    func removeExercisesByTitle(_ title: String) -> Int {
        let before = todaysPlan.count
        todaysPlan.removeAll { $0.title == title }
        let removed = before - todaysPlan.count
        if removed > 0 { saveTodaysPlan() }
        return removed
    }

    /// Remove plan items matching the given id. Returns number removed.
    @discardableResult
    func removeExercisesById(_ id: String) -> Int {
        let before = todaysPlan.count
        todaysPlan.removeAll { $0.id == id }
        let removed = before - todaysPlan.count
        if removed > 0 { saveTodaysPlan() }
        return removed
    }
    
    // MARK: - Persistence (Recommended optional)
    
    /// Save today's plan to UserDefaults
    func saveTodaysPlan() {
        do {
            let data = try JSONEncoder().encode(todaysPlan)
            UserDefaults.standard.set(data, forKey: todaysPlanStorageKey)
        } catch {
            print("Error saving todaysPlan: \(error)")
        }
    }
    
    /// Load saved plan from UserDefaults (if available)
    func loadSavedPlan() {
        guard let data = UserDefaults.standard.data(forKey: todaysPlanStorageKey) else {
            // No saved plan — keep bundle data
            return
        }
        do {
            let saved = try JSONDecoder().decode([PlanItem].self, from: data)
            // Replace todaysPlan with saved data
            self.todaysPlan = saved
        } catch {
            print("Error decoding saved todaysPlan: \(error)")
        }
    }
    
    /// Remove stored saved plan (for debugging)
    func clearSavedPlan() {
        UserDefaults.standard.removeObject(forKey: todaysPlanStorageKey)
    }
}
