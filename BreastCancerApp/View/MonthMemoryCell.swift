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
    @IBOutlet private weak var menuButton: UIButton!
    
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    private let calendar = Calendar.current
    private var imageAspectRatioConstraint: NSLayoutConstraint?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        dateLabel.text = nil
        noteLabel.text = nil
        noteLabel.isHidden = true
        onEdit = nil
        onDelete = nil
        
        if let constraint = imageAspectRatioConstraint {
            imageView.removeConstraint(constraint)
            imageAspectRatioConstraint = nil
        }
    }
    
    func configure(with memory: Memory) {
        imageView.image = memory.image
        
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
        
        if calendar.isDateInToday(memory.date) {
            dateLabel.text = "Today"
        } else if calendar.isDateInYesterday(memory.date) {
            dateLabel.text = "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            dateLabel.text = formatter.string(from: memory.date)
        }
        
        if let note = memory.note, !note.isEmpty {
            noteLabel.text = note
            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }
    }
    
    @IBAction private func menuButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.onEdit?()
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.onDelete?()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Required for iPad popover
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        parentViewController?.present(alert, animated: true)
    }
}

private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController { return vc }
            responder = next
        }
        return nil
    }
}
