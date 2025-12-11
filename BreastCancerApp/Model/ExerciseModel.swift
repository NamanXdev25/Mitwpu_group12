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
}

struct ExerciseItem: Codable {
    var title: String
    var category: String
    var imageName: String
}

// (Note: We removed 'AppData' struct because we don't need a wrapper anymore!)

// --- 2. THE MANAGER ---

class ExerciseManager {
    
    var todaysPlan: [PlanItem] = []
    var myExercises: [ExerciseItem] = []
    var exploreItems: [ExerciseItem] = []
    
    init() {
        loadAllData()
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
    
    // Logic: Toggle Checkmark
    func togglePlanItem(at index: Int) {
        if index < todaysPlan.count {
            todaysPlan[index].isCompleted.toggle()
        }
    }
    
    // Logic: Add to Plan
    func addExerciseToPlan(_ exercise: ExerciseItem) {
        let newItem = PlanItem(
            id: UUID().uuidString,
            title: exercise.title,
            subtitle: exercise.category,
            time: "5 min",
            isCompleted: false
        )
        todaysPlan.insert(newItem, at: 0)
    }
    
    func addPlanItem(_ item: PlanItem) {
          // Insert at TOP of the list
          todaysPlan.insert(item, at: 0)
      }
}
