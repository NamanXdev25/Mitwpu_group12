//
//  AppointmentModel.swift
//  Appointments
//
//  Created by Naman Bhansali on 10/01/26.
//

import UIKit

// MARK: - AppointmentItem Model
struct AppointmentItem {
    let id: String
    let title: String
    let category: String
    let date: String
    let time: String
    let reminderEnabled: Bool
    let reminderOffsets: [ReminderOffset]   // ← NEW
    let note: String
    let colorIndex: Int

    var indicatorColor: UIColor {
        return AppointmentType(rawValue: colorIndex)?.color ?? .systemOrange
    }

    var appointmentType: AppointmentType? {
        return AppointmentType(rawValue: colorIndex)
    }
}

// MARK: - ReminderOffset   ← NEW ENUM
enum ReminderOffset: String, Codable, CaseIterable {
    case atTime = "At time of appointment"
    case min15  = "15 minutes before"
    case min30  = "30 minutes before"
    case hour1  = "1 hour before"
    case hour2  = "2 hours before"
    case day1   = "1 day before"
    case day2   = "2 days before"
}

// MARK: - AppointmentType
enum AppointmentType: Int, CaseIterable {
    case chemotherapy = 0
    case doctorVisit  = 1

    var title: String {
        switch self {
        case .chemotherapy: return "Chemotherapy"
        case .doctorVisit:  return "     Doctor Visit"
        }
    }

    var pickerTitle: String {
        switch self {
        case .chemotherapy: return "Chemotherapy"
        case .doctorVisit:  return "Doctor Visit"
        }
    }

    var color: UIColor {
        let chemoColor      = UIColor(named: "chemotherapyindicator")!
        let doctorVisitColor = UIColor(named: "DoctorVisitindicator")!
        switch self {
        case .chemotherapy: return chemoColor
        case .doctorVisit:  return doctorVisitColor
        }
    }
}
