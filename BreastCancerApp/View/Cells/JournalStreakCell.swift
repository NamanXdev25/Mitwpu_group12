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
    
    
    static let reuseIdentifier = "JournalStreakCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
    
    }
    
    func configure(streak: Int) {
            titleLabel.text = "Current Streak"
            countLabel.text = "\(streak)"
            daysLabel.text = "days"
            flameImageView.image = UIImage(systemName: "flame.fill")
    }

}
