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
    
    func configure(text: String, isSelected: Bool) {
        titleLabel.text = text
        
        if isSelected {
            containerView.backgroundColor = UIColor(named: "primary_color")
            titleLabel.textColor = .white
        } else {
            containerView.backgroundColor = UIColor(named: "filter_buttons")
            titleLabel.textColor = .darkGray
        }
    }

}
