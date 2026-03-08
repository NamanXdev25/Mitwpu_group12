//
//  SectionTitleCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 05/03/26.
//

import UIKit

class SectionTitleCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = "Notifications"
    }

}
