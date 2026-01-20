//
//  FavoriteSessionCell.swift
//  ChemoCompanion
//
//  Created by ChemoCompanion Dev on 28/11/25.
//

import UIKit

class FavoriteSessionCell: UICollectionViewCell {

    // OUTLETS
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var titleContainerView: UIView! // White capsule at bottom
    @IBOutlet weak var heartContainerView: UIView! // NEW: Circle view behind heart

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Round the corners of the main cell
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        // 2. Style the white capsule (bottom)
        titleContainerView.layer.cornerRadius = titleContainerView.frame.height / 2
        titleContainerView.layer.masksToBounds = true
        
        // 3. Style the heart container (top right)
        // This makes it a perfect circle
        heartContainerView.layer.cornerRadius = heartContainerView.frame.height / 2
        heartContainerView.layer.masksToBounds = true
        heartContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.8) // Optional: Semi-transparent white
    }

    func configureCell(session: BreathingSession) {
        titleLabel.text = session.title
        categoryLabel.text = session.category
        sessionImageView.image = UIImage(named: session.imageName)
        
        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)
        likeButton.tintColor = .systemPink
    }
}
