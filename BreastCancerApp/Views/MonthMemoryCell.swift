//
//  MonthMemoryCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/02/26.
//

import UIKit

final class MonthMemoryCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MonthMemoryCell"
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    
    private let calendar = Calendar.current
    private var imageAspectRatioConstraint: NSLayoutConstraint?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        dateLabel.text = nil
        noteLabel.text = nil
        noteLabel.isHidden = true
        
        if let constraint = imageAspectRatioConstraint {
            imageView.removeConstraint(constraint)
            imageAspectRatioConstraint = nil
        }
    }
    
    func configure(with memory: Memory) {
        imageView.image = memory.image
        
        // Set aspect ratio constraint based on image
        if let image = memory.image {
            let aspectRatio = image.size.height / image.size.width
            
            if let oldConstraint = imageAspectRatioConstraint {
                imageView.removeConstraint(oldConstraint)
            }
            
            imageAspectRatioConstraint = imageView.heightAnchor.constraint(
                equalTo: imageView.widthAnchor,
                multiplier: aspectRatio
            )
            imageAspectRatioConstraint?.priority = .required
            imageAspectRatioConstraint?.isActive = true
        }
        
        // Configure date
        if calendar.isDateInToday(memory.date) {
            dateLabel.text = "Today"
        } else if calendar.isDateInYesterday(memory.date) {
            dateLabel.text = "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            dateLabel.text = formatter.string(from: memory.date)
        }
        
        // Configure note
        if let note = memory.note, !note.isEmpty {
            noteLabel.text = note
            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }
    }
}
