//
//  SymptomLog.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import Foundation

struct SymptomLog {
    let id: String
    let symptomId: String
    let symptomName: String
    let severity: Int // 0-4 (0=mild, 4=severe)
    let note: String
    let timestamp: Date
    
    init(symptomId: String, symptomName: String, severity: Int, note: String = "") {
        self.id = UUID().uuidString
        self.symptomId = symptomId
        self.symptomName = symptomName
        self.severity = severity
        self.note = note
        self.timestamp = Date()
    }
    
    init(symptomId: String, symptomName: String, severity: Int, note: String = "", timestamp: Date) {
        self.id = UUID().uuidString
        self.symptomId = symptomId
        self.symptomName = symptomName
        self.severity = severity
        self.note = note
        self.timestamp = timestamp
    }
}
