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
    let title: String        // User's custom title
    let category: String     // "Chemotherapy" or "Doctor Visit"
    let date: String
    let time: String
    let reminderEnabled: Bool
    let note: String
    let colorIndex: Int
    
    var indicatorColor: UIColor {
        return AppointmentType(rawValue: colorIndex)?.color ?? .systemOrange
    }
    
    var appointmentType: AppointmentType? {
        return AppointmentType(rawValue: colorIndex)
    }
}

// MARK: - AppointmentType Enum
enum AppointmentType: Int, CaseIterable {
    case chemotherapy = 0
    case doctorVisit = 1
    
    var title: String {
        switch self {
        case .chemotherapy:
            return "Chemotherapy"
        case .doctorVisit:
            return "     Doctor Visit"
        }
    }
    
    var pickerTitle: String {
        switch self {
        case .chemotherapy:
            return "Chemotherapy"
        case .doctorVisit:
            return "Doctor Visit"
        }
    }
    
    var color: UIColor {
        let chemocolor = UIColor(named: "chemotherapyindicator")!
        let DoctorVisitcolor = UIColor(named: "DoctorVisitindicator")!
        switch self {
        case .chemotherapy:
            return chemocolor
        case .doctorVisit:
            return DoctorVisitcolor
        }
    }
}
