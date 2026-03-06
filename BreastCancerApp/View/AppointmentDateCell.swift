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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure selection layer stays circular even after layout changes
        selectionLayer.layer.cornerRadius = selectionLayer.frame.width / 2
    }
    
    func configure(day: String, isSelected: Bool, hasAppointments: Bool, isToday: Bool) {
        dayLabel.text = day
        dayLabel.textColor = .black
        dayLabel.isHidden = false
        dayLabel.alpha = 1.0
        dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        selectionLayer.backgroundColor = .clear
        selectionLayer.isHidden = false

        if day.isEmpty { return }

        if isToday {
            selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
            dayLabel.textColor = .white
            dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            return
        }

        if hasAppointments {
            dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            dayLabel.textColor = UIColor(named: "primary_pink") ?? UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
        }

        if isSelected {
            selectionLayer.backgroundColor = hasAppointments
                ? (UIColor(named: "primary_pink") ?? UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)).withAlphaComponent(0.15)
                : .clear
        }
    }
}
