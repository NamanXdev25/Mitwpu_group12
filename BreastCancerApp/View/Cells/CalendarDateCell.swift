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
    
    override func layoutSubviews() {
        super.layoutSubviews()

        selectionLayer.layer.cornerRadius = selectionLayer.frame.height / 2
        selectionLayer.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionLayer.backgroundColor = .clear
        dotView.isHidden = true
        dayLabel.textColor = .black
    }
    
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
