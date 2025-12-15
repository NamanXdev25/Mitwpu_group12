//
//  JournalStreakCellCollectionViewCell.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import UIKit

class JournalStreakCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var flameImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inactiveLabel: UILabel!
    
    
    static let reuseIdentifier = "JournalStreakCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(streak: Int) {
        if streak == 0 {
            titleLabel.isHidden = true
            countLabel.isHidden = true
            daysLabel.isHidden = true
            flameImageView.isHidden = true
            inactiveLabel.isHidden = false
        } else {
            countLabel.text = "\(streak)"
            titleLabel.isHidden = false
            countLabel.isHidden = false
            daysLabel.isHidden = false
            flameImageView.isHidden = false
            inactiveLabel.isHidden = true
        }
    }


}
