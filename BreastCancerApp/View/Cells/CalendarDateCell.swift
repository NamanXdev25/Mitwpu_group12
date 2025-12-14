//
//  CalendarDateCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 27/11/25.
//

import UIKit

class CalendarDateCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!
    @IBOutlet weak var dotView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Default style
        selectionLayer.backgroundColor = .clear
        dayLabel.textColor = .black
        
        dotView.layer.cornerRadius = 3
        dotView.isHidden = true
    }
    
    // --- FIX FOR PERFECT CIRCLES ---
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 1. Ensure the view is a circle (Width / 2)
        // If your constraint in Storyboard is 30x30, this will be 15.
        // If it stretches, this ensures it stays round.
        selectionLayer.layer.cornerRadius = selectionLayer.frame.height / 2
        selectionLayer.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionLayer.backgroundColor = .clear
        dotView.isHidden = true
        dayLabel.textColor = .black
    }
    /*
     func configure(day: String, status: String) {
     dayLabel.text = day
     
     // Reset
     selectionLayer.backgroundColor = .clear
     dayLabel.textColor = .black
     
     if day.isEmpty { return }
     
     switch status {
     case "selected":
     // Dark Pink
     selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.4, blue: 0.5, alpha: 1.0)
     dayLabel.textColor = .white
     
     case "completed":
     // Light Pink
     selectionLayer.backgroundColor = UIColor(red: 0.95, green: 0.85, blue: 0.88, alpha: 1.0)
     dayLabel.textColor = .black
     
     default:
     selectionLayer.backgroundColor = .clear
     }
     }
     */
    
    func configure(
        day: String,
        hasJournal: Bool,
        isSelected: Bool
    ) {
        dayLabel.text = day
        
        // Reset
        selectionLayer.backgroundColor = .clear
        dotView.isHidden = true
        dayLabel.textColor = .black
        
        guard !day.isEmpty else { return }
        
        // Show dot if journal exists
        if hasJournal {
            dotView.isHidden = false
        }
        
        // Soft highlight for selected date
        if isSelected {
            selectionLayer.backgroundColor =
            UIColor(named: "PrimaryColor")?.withAlphaComponent(0.2)
            
            dayLabel.textColor = UIColor(named: "PrimaryColor")
        }
    }
}
