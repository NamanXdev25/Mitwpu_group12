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
        // Initialization code
    }

}
