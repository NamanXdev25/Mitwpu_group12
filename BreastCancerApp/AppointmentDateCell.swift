//
//  AppointmentDateCell.swift
//  Appointments
//
//  Created by Naman Bhansali on 11/01/26.
//

import UIKit

class AppointmentDateCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Make selection layer circular
        selectionLayer.layer.cornerRadius = selectionLayer.frame.width / 2
        selectionLayer.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure selection layer stays circular even after layout changes
        selectionLayer.layer.cornerRadius = selectionLayer.frame.width / 2
    }
    
    func configure(day: String, isSelected: Bool, hasAppointments: Bool, appointmentTypes: [AppointmentType], isToday: Bool) {
        // Reset state
        dayLabel.text = day
        dayLabel.textColor = .black
        dayLabel.isHidden = false
        dayLabel.alpha = 1.0
        dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        selectionLayer.backgroundColor = .clear
        selectionLayer.isHidden = false
        
        // Early exit for empty cells
        if day.isEmpty {
            dayLabel.text = ""
            return
        }
        
        // Handle today - always show dark pink/red background with white text
        if isToday {
            selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
            dayLabel.textColor = .white
            dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            return
        }
        
        // Determine the color for this date based on appointments
        var dateColor: UIColor = .black
        
        if hasAppointments && !appointmentTypes.isEmpty {
            // If there's only one type, use its color
            if appointmentTypes.count == 1 {
                dateColor = appointmentTypes[0].color
            } else {
                // If both types exist, use chemotherapy color (orange) as priority
                dateColor = AppointmentType.chemotherapy.color
            }
            
            // Make text bold for dates with appointments
            dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }
        
        // Set text color
        dayLabel.textColor = dateColor
        
        // Handle selected date
        if isSelected {
            if hasAppointments {
                // Selected date WITH appointments - show circle with low opacity in appointment color
                selectionLayer.backgroundColor = dateColor.withAlphaComponent(0.15)
            } else {
                // Selected date WITHOUT appointments - show light pink background
//                let lightPink = UIColor(red: 0.98, green: 0.89, blue: 0.92, alpha: 1.0)
//                selectionLayer.backgroundColor = lightPink
                dayLabel.textColor = .black
            }
        } else {
            // Not selected - no background
            selectionLayer.backgroundColor = .clear
        }
    }
}
