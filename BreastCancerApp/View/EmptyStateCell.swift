//
//  EmptyStateCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/01/26.
//

import UIKit

class EmptyStateCell: UICollectionViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(message: String) {
        messageLabel.text = message
    }
}
