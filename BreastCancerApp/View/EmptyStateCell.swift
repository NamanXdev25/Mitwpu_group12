//
//  EmptyStateCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 28/11/25.
//

import UIKit

class EmptyStateCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Style the box to look like a placeholder
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.layer.masksToBounds = true
    }
}
