//FilterCell.swift
//  ChemoCompanion
//
//  Created by Shloka on 28/11/25.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Configure the look based on whether it is selected
    func configure(text: String, isSelected: Bool) {
        titleLabel.text = text
        
        if isSelected {
            // Active Style (Pink)
            containerView.backgroundColor = UIColor(named: "primary_color") // A nice pink
            titleLabel.textColor = .white
        } else {
            // Inactive Style (Light Gray)
            containerView.backgroundColor = UIColor(named: "filter_buttons")
            titleLabel.textColor = .darkGray
        }
    }

}
