//
//  CareModel.swift
//  BreastCancerApp
//
//  Updated for DiffableDataSource pattern
//

import Foundation

// MARK: - Section Types
enum CareSectionType: Int, CaseIterable {
    case todayHeader = 0
    case hydration
    case medication
    case exercise
    case symptoms
    case appointmentHeader
    case appointments
    case healthInsights
}

// MARK: - Item Types
enum CareItemType {
    case header(title: String, showManage: Bool)
    case hydration
    case medication(title: String, status: String, imageName: String?)
    case exercise(title: String, duration: String, imageName: String?)
    case symptoms(title: String, loggedSymptoms: [String])
    case appointment(month: String, day: String, title: String, doctor: String, time: String)
    case healthInsights
}

// MARK: - Care Item Model
struct CareItem: Hashable {
    let id: UUID
    let type: CareItemType
    
    // Hashable conformance
    static func == (lhs: CareItem, rhs: CareItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CareItemType Hashable Extension
extension CareItemType: Hashable {
    static func == (lhs: CareItemType, rhs: CareItemType) -> Bool {
        switch (lhs, rhs) {
        case (.header(let lTitle, let lShow), .header(let rTitle, let rShow)):
            return lTitle == rTitle && lShow == rShow
        case (.hydration, .hydration):
            return true
        case (.medication(let lTitle, let lStatus, let lImage), .medication(let rTitle, let rStatus, let rImage)):
            return lTitle == rTitle && lStatus == rStatus && lImage == rImage
        case (.exercise(let lTitle, let lDuration, let lImage), .exercise(let rTitle, let rDuration, let rImage)):
            return lTitle == rTitle && lDuration == rDuration && lImage == rImage
        case (.symptoms(let lTitle, let lSymptoms), .symptoms(let rTitle, let rSymptoms)):
            return lTitle == rTitle && lSymptoms == rSymptoms
        case (.appointment(let lMonth, let lDay, let lTitle, let lDoctor, let lTime),
              .appointment(let rMonth, let rDay, let rTitle, let rDoctor, let rTime)):
            return lMonth == rMonth && lDay == rDay && lTitle == rTitle && lDoctor == rDoctor && lTime == rTime
        case (.healthInsights, .healthInsights):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .header(let title, let showManage):
            hasher.combine("header")
            hasher.combine(title)
            hasher.combine(showManage)
        case .hydration:
            hasher.combine("hydration")
        case .medication(let title, let status, let imageName):
            hasher.combine("medication")
            hasher.combine(title)
            hasher.combine(status)
            hasher.combine(imageName)
        case .exercise(let title, let duration, let imageName):
            hasher.combine("exercise")
            hasher.combine(title)
            hasher.combine(duration)
            hasher.combine(imageName)
        case .symptoms(let title, let loggedSymptoms):
            hasher.combine("symptoms")
            hasher.combine(title)
            hasher.combine(loggedSymptoms)
        case .appointment(let month, let day, let title, let doctor, let time):
            hasher.combine("appointment")
            hasher.combine(month)
            hasher.combine(day)
            hasher.combine(title)
            hasher.combine(doctor)
            hasher.combine(time)
        case .healthInsights:
            hasher.combine("healthInsights")
        }
    }
}

// MARK: - Sample Data (Optional - for testing)
struct CareModel {
    
    static let sampleSymptoms = ["Fatigue", "Nausea", "Pain", "+2"]
    
    static let sampleAppointments = [
        (month: "FEB", day: "15", title: "Oncology Checkup", doctor: "Dr. Sarah Johnson", time: "10:00 AM"),
        (month: "FEB", day: "22", title: "Blood Work", doctor: "Lab Services", time: "9:00 AM")
    ]
}
