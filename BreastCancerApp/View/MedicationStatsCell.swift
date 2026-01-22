//
//  MedicationStatsCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 20/01/26.
//

import UIKit

class MedicationStatsCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.masksToBounds = true
    }

    func configure(with medication: Medication, isFirst: Bool, isLast: Bool) {
        titleLabel.text = medication.name
        timeLabel.text = medication.time
        
        // Reset corner radius
        containerView.layer.cornerRadius = 0
        containerView.layer.maskedCorners = []
        
        if isFirst && isLast {
            // Single item - round all corners
            containerView.layer.cornerRadius = 12
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            // First item - round top corners only
            containerView.layer.cornerRadius = 12
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            // Last item - round bottom corners only
            containerView.layer.cornerRadius = 12
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}
