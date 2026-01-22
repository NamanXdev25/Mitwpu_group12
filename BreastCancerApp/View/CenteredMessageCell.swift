//
//  CenteredMessageCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 20/01/26.
//
import UIKit

class CenteredMessageCell: UICollectionViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(message: String) {
        messageLabel.text = message
    }
}
