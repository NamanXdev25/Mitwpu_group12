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

    var onContinueTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        continueButton.backgroundColor = UIColor.systemPink
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 26
        continueButton.clipsToBounds = true

        footerLabel.textColor = UIColor.lightGray
        footerLabel.textAlignment = .center
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        onContinueTapped?()
    }
}
