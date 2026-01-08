//
//  SymptomsDataSource.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import Foundation

class SymptomDataSource {
    static let shared = SymptomDataSource()
    
    private init() {}
    
    // All available symptoms
    private var allSymptoms: [Symptom] = [
        Symptom(id: "1", name: "Fatigue", isInUserList: true),
        Symptom(id: "2", name: "Nausea", isInUserList: true),
        Symptom(id: "3", name: "Pain", isInUserList: true),
        Symptom(id: "4", name: "Headache", isInUserList: false),
        Symptom(id: "5", name: "Dizziness", isInUserList: false),
        Symptom(id: "6", name: "Fever", isInUserList: false),
        Symptom(id: "7", name: "Cough", isInUserList: false)
    ]
    
    // Logged symptoms for today
    private var todayLogs: [SymptomLog] = []
    
    // MARK: - User List Management
    func getUserSymptoms() -> [Symptom] {
        return allSymptoms.filter { $0.isInUserList }
    }
    
    func getAvailableSymptoms() -> [Symptom] {
        return allSymptoms.filter { !$0.isInUserList }
    }
    
    func addSymptomToUserList(symptomId: String) {
        if let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) {
            allSymptoms[index].isInUserList = true
        }
    }
    
    func removeSymptomFromUserList(symptomId: String) {
        if let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) {
            allSymptoms[index].isInUserList = false
        }
    }
    
    // MARK: - Logging Management
    func logSymptom(symptomId: String, symptomName: String, severity: Int) {
        let log = SymptomLog(symptomId: symptomId, symptomName: symptomName, severity: severity)
        todayLogs.append(log)
    }
    
    func getTodayLogs() -> [SymptomLog] {
        return todayLogs.sorted { $0.timestamp > $1.timestamp }
    }
    
    // 🔥 NEW: Delete log entry
    func deleteLog(logId: String) {
        todayLogs.removeAll { $0.id == logId }
    }
    
    func getSeverityText(for severity: Int) -> String {
        switch severity {
        case 0: return "Mild"
        case 1: return "Mild-Moderate"
        case 2: return "Moderate"
        case 3: return "Moderate-Severe"
        case 4: return "Severe"
        default: return "Unknown"
        }
    }
}
