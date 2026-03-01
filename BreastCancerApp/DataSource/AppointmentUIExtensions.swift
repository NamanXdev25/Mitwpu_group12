//
//  AppointmentUIExtensions.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 01/03/26.
//

import UIKit

extension AppointmentItem {
    var indicatorColor: UIColor {
        AppointmentType(rawValue: colorIndex)?.color ?? .systemOrange
    }

    var appointmentType: AppointmentType? {
        AppointmentType(rawValue: colorIndex)
    }
}

extension AppointmentType {
    var color: UIColor {
        let chemoColor = UIColor(named: "chemotherapyindicator")!
        let doctorVisitColor = UIColor(named: "DoctorVisitindicator")!

        switch self {
        case .chemotherapy: return chemoColor
        case .doctorVisit: return doctorVisitColor
        }
    }
}
