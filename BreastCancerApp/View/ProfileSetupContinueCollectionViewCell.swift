//
//  ContinueCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class ProfileSetupContinueCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var footerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // App theme pink
        continueButton.backgroundColor = UIColor.systemPink
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 26
        continueButton.clipsToBounds = true

        footerLabel.textColor = UIColor.lightGray
        footerLabel.textAlignment = .center
    }
}

