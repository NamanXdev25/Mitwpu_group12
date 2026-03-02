//
//  OnboardingFocusSectionHeaderCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 02/03/26.
//

import UIKit

class OnboardingFocusSectionHeaderCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
