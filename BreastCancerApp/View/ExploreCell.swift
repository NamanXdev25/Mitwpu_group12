//
//  JournalActionCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 25/11/25.
//

import UIKit

class ExploreCell: UICollectionViewCell {

    var didTap: (() -> Void)?
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tap)
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
