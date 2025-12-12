//
//  MedicationHistory.swift
//  BreastCancerApp
//
//  Created by Shloka on 12/12/25.
//
import Foundation

class MedicationHistory {
    static let shared = MedicationHistory() // Singleton to access from anywhere
    
    // Key: Date String (e.g., "12-12-2025"), Value: (Taken, Goal)
    private var dailyLogs: [String: (taken: Int, goal: Int)] = [:]
    
    private init() {}
    
    // Save or Update progress for a specific date
    func updateProgress(date: Date, taken: Int, goal: Int) {
        let key = formatDate(date)
        dailyLogs[key] = (taken, goal)
    }
    
    // Get progress for a specific date
    func getProgress(for date: Date) -> (taken: Int, goal: Int) {
        let key = formatDate(date)
        // Default to (0, 0) if no data exists
        return dailyLogs[key] ?? (0, 0)
    }
    
    // Helper to make the key simple
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}
