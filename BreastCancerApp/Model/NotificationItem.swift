//
//  NotificationItem.swift
//  BreastCancerApp
//
//  Created by Shloka on 05/03/26.
//

import Foundation

struct NotificationItem {
    
    let title: String
    var isEnabled: Bool
    
}

extension NotificationItem {
    
    static func defaultItems() -> [NotificationItem] {
        
        return [
            NotificationItem(title: "Exercise", isEnabled: true),
            NotificationItem(title: "Hydration", isEnabled: true),
            NotificationItem(title: "Appointments", isEnabled: true),
            NotificationItem(title: "Medications", isEnabled: true)
        ]
        
    }
}
