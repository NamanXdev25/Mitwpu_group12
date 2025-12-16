//
//  JournalActionCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 25/11/25.
//

import UIKit

class MindfulnessExploreCell: UICollectionViewCell {

    var didTap: (() -> Void)?
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @objc private func tapped() {
        didTap?()
    }
    
    func configure(title: String, subtitle: String, icon: UIImage) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            iconView.image = icon
    }
}
