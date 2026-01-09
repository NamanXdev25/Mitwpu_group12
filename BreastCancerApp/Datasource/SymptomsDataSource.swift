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
    
    private let userSymptomsOrderKey = "userSymptomsOrder"
    
    // All available symptoms - loaded from JSON
    private var allSymptoms: [Symptom] = []
    
    // Logged symptoms for today
    private var todayLogs: [SymptomLog] = []
    
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
    
    // ... rest of your existing methods stay the same ...
    
    func getUserSymptoms() -> [Symptom] {
        let userSymptoms = allSymptoms.filter { $0.isInUserList }
        let savedOrder = UserDefaults.standard.stringArray(forKey: userSymptomsOrderKey)
        
        guard let order = savedOrder, !order.isEmpty else {
            return userSymptoms
        }
        
        var ordered: [Symptom] = []
        for id in order {
            if let symptom = userSymptoms.first(where: { $0.id == id }) {
                ordered.append(symptom)
            }
        }
        return ordered
    }
    
    func getAvailableSymptoms() -> [Symptom] {
        return allSymptoms.filter { !$0.isInUserList }
    }
    
    func addSymptomToUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = true
        
        var order = UserDefaults.standard.stringArray(forKey: userSymptomsOrderKey) ?? []
        if !order.contains(symptomId) {
            order.append(symptomId)
            UserDefaults.standard.set(order, forKey: userSymptomsOrderKey)
        }
    }
    
    func removeSymptomFromUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = false
        
        var order = UserDefaults.standard.stringArray(forKey: userSymptomsOrderKey) ?? []
        order.removeAll { $0 == symptomId }
        UserDefaults.standard.set(order, forKey: userSymptomsOrderKey)
    }
    
    func updateUserSymptomsOrder(_ symptoms: [Symptom]) {
        let orderedIds = symptoms.map { $0.id }
        UserDefaults.standard.set(orderedIds, forKey: userSymptomsOrderKey)
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
}
