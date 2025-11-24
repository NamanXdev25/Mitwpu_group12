//
//  JournalStatsCell.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import UIKit

class JournalStatsCell: UICollectionViewCell {

    static let reuseIdentifier = "JournalStatsCell"
    
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var totalSubtitleLabel: UILabel!

    @IBOutlet weak var weekCountLabel: UILabel!
    @IBOutlet weak var weekSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(total: Int, thisWeek: Int) {
            totalCountLabel.text = "\(total)"
            totalSubtitleLabel.text = "Total Journals"

            weekCountLabel.text = "\(thisWeek)"
            weekSubtitleLabel.text = "This Week"
    }

}
