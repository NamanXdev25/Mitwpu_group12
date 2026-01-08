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
    
    private let userSymptomsOrderKey = "userSymptomsOrder"

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

        // Only symptoms that belong to the user
        let userSymptoms = allSymptoms.filter { $0.isInUserList }

        let savedOrder = UserDefaults.standard.stringArray(
            forKey: userSymptomsOrderKey
        )

        // 🔥 First run or no saved order → return natural order
        guard let order = savedOrder, !order.isEmpty else {
            return userSymptoms
        }

        // Rebuild in saved order
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

        var order = UserDefaults.standard.stringArray(
            forKey: userSymptomsOrderKey
        ) ?? []

        if !order.contains(symptomId) {
            order.append(symptomId)
            UserDefaults.standard.set(order, forKey: userSymptomsOrderKey)
        }
    }

    
    func removeSymptomFromUserList(symptomId: String) {
        guard let index = allSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }

        allSymptoms[index].isInUserList = false

        var order = UserDefaults.standard.stringArray(
            forKey: userSymptomsOrderKey
        ) ?? []

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
