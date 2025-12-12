//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Shloka Shetty on 3/12/25.
//
import UIKit

class CalendarDateCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!
    
    // Your app's brand pink
    let darkPink = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionLayer.backgroundColor = .clear
        dayLabel.textColor = .black
    }
    
    // Ensure the circle stays round
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionLayer.layer.cornerRadius = selectionLayer.frame.height / 2
        selectionLayer.layer.masksToBounds = true
    }
    
    // --- THIS IS THE PART THAT MATCHES YOUR VIEW CONTROLLER ---
    func configure(day: String, isToday: Bool, isSelected: Bool, takenCount: Int, goalCount: Int) {
        
        dayLabel.text = day
        
        // 1. Handle Empty Squares
        if day.isEmpty {
            selectionLayer.backgroundColor = .clear
            dayLabel.text = ""
            return
        }
        
        // --- HIG STYLE LOGIC ---
        
        // A. If Selected: Solid Circle + White Text (Overrides everything)
        if isSelected {
            selectionLayer.backgroundColor = darkPink
            dayLabel.textColor = .white
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return
        }
        
        // B. If Today (but not selected): Bold Pink Text, No Background
        if isToday {
            selectionLayer.backgroundColor = .clear
            dayLabel.textColor = darkPink // Your brand color
            dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .heavy) // Extra Bold to stand out
        }
        // C. Standard Day: Black Text, Regular Font
        else {
            dayLabel.textColor = .black
            dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }
        
        // D. Handle Progress Colors (Only if NOT selected)
        // We only color the background if it's NOT today and NOT selected (or blend it)
        // For a cleaner look, usually, progress is shown for PAST days.
        if !isSelected && !isToday {
            if goalCount == 0 {
                selectionLayer.backgroundColor = .clear
            } else if takenCount >= goalCount {
                // Completed day in the past
                selectionLayer.backgroundColor = darkPink.withAlphaComponent(0.3)
            } else if takenCount > 0 {
                // Partially completed
                selectionLayer.backgroundColor = darkPink.withAlphaComponent(0.1)
            } else {
                selectionLayer.backgroundColor = .clear
            }
        }
    }
}
