//
//  MedicationHistory.swift
//  Medication
//
//  Created by Naman Bhansali on 16/01/26.
//

import Foundation

struct MedicationHistoryEntry {
    let date: Date
    var medications: [Medication]
    var taken: Int
    var goal: Int
}

class MedicationHistory {
    static let shared = MedicationHistory()
    
    private var history: [String: MedicationHistoryEntry] = [:]
    
    private init() {}
    
    private func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func updateProgress(date: Date, taken: Int, goal: Int) {
        let key = dateKey(from: date)
        
        if var entry = history[key] {
            entry.taken = taken
            entry.goal = goal
            history[key] = entry
        } else {
            let entry = MedicationHistoryEntry(date: date, medications: [], taken: taken, goal: goal)
            history[key] = entry
        }
    }
    
    func saveMedications(_ medications: [Medication], for date: Date) {
        let key = dateKey(from: date)
        
        let taken = medications.filter { $0.isTaken }.count
        let goal = medications.count
        
        let entry = MedicationHistoryEntry(date: date, medications: medications, taken: taken, goal: goal)
        history[key] = entry
    }
    
    func getHistory(for date: Date) -> MedicationHistoryEntry? {
        let key = dateKey(from: date)
        return history[key]
    }
    
    func getAllHistory() -> [MedicationHistoryEntry] {
        return Array(history.values).sorted { $0.date > $1.date }
    }
}
