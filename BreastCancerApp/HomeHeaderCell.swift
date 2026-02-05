//
//  HomeHeaderCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//

import UIKit

class HomeHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var HeaderTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Configure
    func configure(title: String) {
        HeaderTitleLabel.text = title
    }
}
