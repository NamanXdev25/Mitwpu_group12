//
//  SampleSymptomData.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 09/01/26.
//

import Foundation

enum SampleSymptomData {
    
    // Helper to create logs at specific days ago
    private static func daysAgo(_ days: Int) -> Date {
        return Date().addingTimeInterval(-Double(days) * 86400)
    }
    
    static let allLogs: [SymptomLog] = [
        
        SymptomLog(
            symptomId: "nausea",
            symptomName: "Nausea",
            severity: 1,
            timestamp: daysAgo(1)
        ),
        SymptomLog(
            symptomId: "pain",
            symptomName: "Pain",
            severity: 3,
            timestamp: daysAgo(1).addingTimeInterval(-3600)
        ),
        SymptomLog(
            symptomId: "fatigue",
            symptomName: "Fatigue",
            severity: 3,
            timestamp: daysAgo(3)
        ),
        SymptomLog(
            symptomId: "headache",
            symptomName: "Headache",
            severity: 2,
            timestamp: daysAgo(3).addingTimeInterval(-7200)
        ),
        SymptomLog(
            symptomId: "nausea",
            symptomName: "Nausea",
            severity: 4,
            timestamp: daysAgo(5)
        ),
        
        SymptomLog(
            symptomId: "pain",
            symptomName: "Pain",
            severity: 2,
            timestamp: daysAgo(7)
        ),
        SymptomLog(
            symptomId: "fatigue",
            symptomName: "Fatigue",
            severity: 4,
            timestamp: daysAgo(7).addingTimeInterval(-5400)
        ),
        SymptomLog(
            symptomId: "insomnia",
            symptomName: "Insomnia",
            severity: 3,
            timestamp: daysAgo(10)
        ),
        SymptomLog(
            symptomId: "nausea",
            symptomName: "Nausea",
            severity: 2,
            timestamp: daysAgo(12)
        ),
        SymptomLog(
            symptomId: "appetite_loss",
            symptomName: "Appetite Loss",
            severity: 3,
            timestamp: daysAgo(12).addingTimeInterval(-1800)
        ),
        SymptomLog(
            symptomId: "fatigue",
            symptomName: "Fatigue",
            severity: 3,
            timestamp: daysAgo(14)
        ),
        SymptomLog(
            symptomId: "pain",
            symptomName: "Pain",
            severity: 4,
            timestamp: daysAgo(14).addingTimeInterval(-3600)
        ),
        SymptomLog(
            symptomId: "headache",
            symptomName: "Headache",
            severity: 1,
            timestamp: daysAgo(17)
        ),
        SymptomLog(
            symptomId: "nausea",
            symptomName: "Nausea",
            severity: 3,
            timestamp: daysAgo(19)
        ),
        SymptomLog(
            symptomId: "fatigue",
            symptomName: "Fatigue",
            severity: 4,
            timestamp: daysAgo(21)
        ),
        SymptomLog(
            symptomId: "insomnia",
            symptomName: "Insomnia",
            severity: 2,
            timestamp: daysAgo(21).addingTimeInterval(-10800)
        ),
        SymptomLog(
            symptomId: "pain",
            symptomName: "Pain",
            severity: 3,
            timestamp: daysAgo(24)
        ),
        SymptomLog(
            symptomId: "nausea",
            symptomName: "Nausea",
            severity: 2,
            timestamp: daysAgo(26)
        ),
        SymptomLog(
            symptomId: "appetite_loss",
            symptomName: "Appetite Loss",
            severity: 4,
            timestamp: daysAgo(26).addingTimeInterval(-7200)
        ),
        SymptomLog(
            symptomId: "fatigue",
            symptomName: "Fatigue",
            severity: 2,
            timestamp: daysAgo(28)
        ),
        SymptomLog(
            symptomId: "headache",
            symptomName: "Headache",
            severity: 3,
            timestamp: daysAgo(30)
        ),
        SymptomLog(
            symptomId: "pain",
            symptomName: "Pain",
            severity: 2,
            timestamp: daysAgo(30).addingTimeInterval(-5400)
        )
    ]
}
