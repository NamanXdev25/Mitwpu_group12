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
        loadSampleLogs()
    }
    
    private var allSymptoms: [Symptom] = []
    private var todayLogs: [SymptomLog] = []
    private var currentUserSymptomsOrder: [String] = []
    
    // load data
    
    private func loadSymptomsFromJSON() {
        guard let url = Bundle.main.url(forResource: "Symptoms", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let symptomsData = try? JSONDecoder().decode(SymptomsData.self, from: data) else {
            print("Failed to load symptoms from JSON")
            return
        }
        
        allSymptoms = symptomsData.symptoms
        print("Loaded \(allSymptoms.count) symptoms from JSON")
    }
    
    private func loadSampleLogs() {
        todayLogs = SampleSymptomData.allLogs
        print("Loaded \(todayLogs.count) sample symptom logs")
    }
    
    // edit list data
    
    func getDescription(for symptomName: String) -> String {
        return allSymptoms.first(where: { $0.name == symptomName })?.description
            ?? "Track this symptom and discuss with your care team if it persists or worsens."
    }
    
    func getUserSymptoms() -> [Symptom] {
        let userSymptoms = allSymptoms.filter { $0.isInUserList }
        guard !currentUserSymptomsOrder.isEmpty else {
            return userSymptoms
        }
        var ordered: [Symptom] = []
        for id in currentUserSymptomsOrder {
            if let symptom = userSymptoms.first(where: { $0.id == id }) {
                ordered.append(symptom)
            }
        }
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
    
    func addSymptomToUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = true
        if !currentUserSymptomsOrder.contains(symptomId) {
            currentUserSymptomsOrder.append(symptomId)
        }
    }
    
    func removeSymptomFromUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }
        allSymptoms[index].isInUserList = false
        currentUserSymptomsOrder.removeAll { $0 == symptomId }
    }
    
    func updateUserSymptomsOrderInMemory(_ symptoms: [Symptom]) {
        currentUserSymptomsOrder = symptoms.map { $0.id }
    }
    
    // log section
    func logSymptom(symptomId: String, symptomName: String, severity: Int) {
        let log = SymptomLog(symptomId: symptomId, symptomName: symptomName, severity: severity)
        todayLogs.append(log)
    }
    
    // today section
    func getTodayLogs() -> [SymptomLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return todayLogs.filter { log in
            calendar.isDate(log.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
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
    
    // Calendar
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
