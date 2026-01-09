//
//  SymptomsDataSource.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

//
//  SymptomsDataSource.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

//
//  SymptomsDataSource.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import Foundation

class SymptomDataSource {
    static let shared = SymptomDataSource()
    
    private init() {
        loadSymptomsFromJSON()
    }
    
    // 🔥 REMOVED: private let userSymptomsOrderKey = "userSymptomsOrder"
    
    // All available symptoms - loaded from JSON
    private var allSymptoms: [Symptom] = []
    
    // Logged symptoms for today
    private var todayLogs: [SymptomLog] = []
    
    // 🔥 NEW: In-memory order (resets on app restart)
    private var currentUserSymptomsOrder: [String] = []
    
    // MARK: - Load from JSON
    private func loadSymptomsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Symptoms", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let symptomsData = try? JSONDecoder().decode(SymptomsData.self, from: data) else {
            print("❌ Failed to load symptoms from JSON")
            return
        }
        
        allSymptoms = symptomsData.symptoms
        print("✅ Loaded \(allSymptoms.count) symptoms from JSON")
    }
    
    // MARK: - Get Description
    func getDescription(for symptomName: String) -> String {
        return allSymptoms.first(where: { $0.name == symptomName })?.description
            ?? "Track this symptom and discuss with your care team if it persists or worsens."
    }
    
    // 🔥 UPDATED: Returns symptoms in current order (in-memory only)
    func getUserSymptoms() -> [Symptom] {
        let userSymptoms = allSymptoms.filter { $0.isInUserList }
        
        // If we have a custom order in memory, use it
        guard !currentUserSymptomsOrder.isEmpty else {
            return userSymptoms
        }
        
        // Sort according to current order
        var ordered: [Symptom] = []
        for id in currentUserSymptomsOrder {
            if let symptom = userSymptoms.first(where: { $0.id == id }) {
                ordered.append(symptom)
            }
        }
        
        // Add any symptoms not in the order list (newly added)
        for symptom in userSymptoms {
            if !ordered.contains(where: { $0.id == symptom.id }) {
                ordered.append(symptom)
            }
        }
        
        return ordered
    }
    
    func getAvailableSymptoms() -> [Symptom] {
        return allSymptoms.filter { !$0.isInUserList }
    }
    
    // 🔥 SIMPLIFIED: No longer saves order to UserDefaults
    func addSymptomToUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = true
        
        // Add to current order if not already there
        if !currentUserSymptomsOrder.contains(symptomId) {
            currentUserSymptomsOrder.append(symptomId)
        }
    }
    
    // 🔥 SIMPLIFIED: No longer saves order to UserDefaults
    func removeSymptomFromUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = false
        
        // Remove from current order
        currentUserSymptomsOrder.removeAll { $0 == symptomId }
    }
    
    // 🔥 NEW: Update order in memory only (does NOT persist)
    func updateUserSymptomsOrderInMemory(_ symptoms: [Symptom]) {
        currentUserSymptomsOrder = symptoms.map { $0.id }
    }
    
    // MARK: - Logging Management
    func logSymptom(symptomId: String, symptomName: String, severity: Int) {
        let log = SymptomLog(symptomId: symptomId, symptomName: symptomName, severity: severity)
        todayLogs.append(log)
    }
    
    func getTodayLogs() -> [SymptomLog] {
        return todayLogs.sorted { $0.timestamp > $1.timestamp }
    }
    
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
    
    // MARK: - Calendar Support
    func getSymptomLogDays() -> Set<Date> {
        let calendar = Calendar.current
        let uniqueDays = Set(todayLogs.map { calendar.startOfDay(for: $0.timestamp) })
        return uniqueDays
    }

    func getSymptomLogs(on date: Date) -> [SymptomLog] {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        
        return todayLogs.filter { log in
            let logDay = calendar.startOfDay(for: log.timestamp)
            return logDay == targetDay
        }.sorted { $0.timestamp > $1.timestamp }
    }
}
