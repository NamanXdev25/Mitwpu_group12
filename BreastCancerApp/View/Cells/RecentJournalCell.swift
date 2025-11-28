//
//  RecentJournalCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 25/11/25.
//

import UIKit

class RecentJournalCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "RecentJournalCell"
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail
    }
    
    func configure(with entry: JournalEntry) {
            titleLabel.text = entry.title
            descriptionLabel.text = entry.content
            dateLabel.text = entry.dateFormatted
    }

}
