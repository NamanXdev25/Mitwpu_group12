//
//  MedicationCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 02/02/26.
//

import UIKit

class MedicationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var adherenceRateLabel: UILabel!
    @IBOutlet weak var dosesTakenLabel: UILabel!
    @IBOutlet weak var dosesMissedLabel: UILabel!
    @IBOutlet var statusIcons: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        func configure(adherenceRate: String, taken: String, missed: String, values: [Int]?) {
            adherenceRateLabel.text = adherenceRate
            dosesTakenLabel.text = taken
            dosesMissedLabel.text = missed
            
            if let values = values {
                for (index, icon) in statusIcons.enumerated() {
                    if index < values.count {
                        let isTaken = values[index] == 1
                        icon.image = UIImage(systemName: isTaken ? "checkmark.circle.fill" : "circle.fill")
                        icon.tintColor = isTaken ? .systemPink : .systemGray4
                    }
                }
            }
        }
    }
}
