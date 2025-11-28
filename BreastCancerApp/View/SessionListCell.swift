//
//  SessionListCell.swift
//  ChemoCompanion
//
//  Created by ChemoCompanion Dev on 28/11/25.
//

import UIKit

class SessionListCell: UICollectionViewCell {

    // OUTLETS
    @IBOutlet weak var containerView: UIView! // The white background card
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel! // "Meditation • 15 min"
    @IBOutlet weak var likeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Style the card background
        containerView.layer.cornerRadius = 16
        // Optional: Add subtle shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        // 2. Style the image
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.layer.masksToBounds = true
    }

    func configureCell(session: BreathingSession) {
        titleLabel.text = session.title
        
        // Combine Category and Duration with a clock symbol
        // e.g. "Meditation 🕑 15 min"
        let clockIcon = "🕑"
        subtitleLabel.text = "\(session.category)  \(clockIcon) \(session.duration)"
        
        thumbnailImageView.image = UIImage(named: session.imageName)
        
        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)
        likeButton.tintColor = session.isFavorite ? .systemPink : .lightGray
    }
}
