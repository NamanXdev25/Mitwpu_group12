//
//  EmptyStateCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 28/11/25.
//

import UIKit

class BreathingEmptyStateCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Style the box to look like a placeholder
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
       
    }
}
