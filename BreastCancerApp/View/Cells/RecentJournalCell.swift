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
    @IBOutlet weak var moreButton: UIButton!
    
    // callbacks to be set by datasource
    private var onEdit: ((JournalEntry) -> Void)?
    private var onDelete: ((JournalEntry) -> Void)?
    private var currentEntry: JournalEntry?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    /*
    func configure(with entry: JournalEntry) {
            titleLabel.text = entry.title
            descriptionLabel.text = entry.content
            dateLabel.text = entry.dateFormatted
    }
     */
    
    func configure(
        with entry: JournalEntry,
        onEdit: @escaping (JournalEntry) -> Void,
        onDelete: @escaping (JournalEntry) -> Void
    ) {
        currentEntry = entry
        self.onEdit = onEdit
        self.onDelete = onDelete

        titleLabel.text = entry.title
        descriptionLabel.text = entry.content
        dateLabel.text = entry.dateFormatted

        // Build menu
        let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            onEdit(entry)
        }
        
        let delete = UIAction(title: "Delete",
                              image: UIImage(systemName: "trash"),
                              attributes: .destructive) { _ in
            onDelete(entry)
        }

        moreButton.menu = UIMenu(children: [edit, delete])
    }

}

