//
//  HomeTodaysGoalCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import UIKit

class HomeTodaysGoalCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var chevronButton: UIButton! // Changed from UIImageView to UIButton
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 13
        
        // Ensure the icon has rounded corners
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        
        // Setup the checkmark style
        if checkmarkImageView.image == nil {
            checkmarkImageView.image = UIImage(systemName: "checkmark")
        }
        checkmarkImageView.tintColor = .systemPink
        
        // --- Setup Chevron Button Look ---
        // 1. Use the system 'chevron.right' symbol
        // 2. Add a font configuration to make it slightly bold
        // 3. Set tint color to light gray
        let chevronConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)
        
        chevronButton.setImage(chevronImage, for: .normal)
        chevronButton.tintColor = .systemGray3
        
        // Optional: If you want the whole cell to handle the tap, disable user interaction on this specific button
        // so it doesn't "eat" the touch event. If you want a specific action on the arrow only, remove this line.
        chevronButton.isUserInteractionEnabled = false
    }
    
    func configure(title: String, points: String, imageName: String, isCompleted: Bool = false) {
        titleLabel.text = title
        pointsLabel.text = points
        
        iconImageView.image = UIImage(named: imageName)
        
        checkmarkImageView.isHidden = !isCompleted
    }
}
