//
//  SectionHeaderView.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 26/11/25.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .black // Default color
    }
}
