//
//  DetailExerciseCellCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 08/12/25.
//


import UIKit

class DetailExerciseCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clockIconImageView: UIImageView!
    @IBOutlet weak var chevronButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Card Style
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .white
        
        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        // 2. Image Style
        exerciseImageView.layer.cornerRadius = 12
        exerciseImageView.contentMode = .scaleAspectFill
        exerciseImageView.clipsToBounds = true
        
        // 3. Text Style (Force Colors)
        titleLabel.textColor = .black
        
        // Ensure title is not compressed
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        //subtitleLabel.textColor = .darkGray
        timeLabel.textColor = .gray
        
        // 4. Icons
        clockIconImageView.tintColor = .systemGray
        clockIconImageView.image = UIImage(systemName: "clock")
        
        // 4. Chevron Style
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        chevronButton.tintColor = .systemGray3
        
        // 5. LAYER FIX: Bring labels to front
        // This ensures they are drawn ON TOP of the containerView
        if let parentView = titleLabel.superview {
            parentView.bringSubviewToFront(titleLabel)
            parentView.bringSubviewToFront(subtitleLabel)
            parentView.bringSubviewToFront(timeLabel)
        }
    }

    func configure(title: String, subtitle: String, time: String, imageName: String) {
        // Fallback for empty title
        titleLabel.text = title.isEmpty ? "Exercise" : title
        subtitleLabel.text = subtitle
        timeLabel.text = time
        
        if let img = UIImage(named: imageName) {
            exerciseImageView.image = img
        } else {
            exerciseImageView.backgroundColor = .systemPink.withAlphaComponent(0.1)
        }
    }
}

/*
import UIKit

class DetailExerciseCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var chevronButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style Card
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .white
        
        // Shadow (Optional)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleLabel.textColor = .black
                
        // Ensure title is not compressed
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
                
        subtitleLabel.textColor = .darkGray
        timeLabel.textColor = .gray
        
        // Style Image
        exerciseImageView.layer.cornerRadius = 12
        exerciseImageView.contentMode = .scaleAspectFill
        exerciseImageView.clipsToBounds = true
        
        // 4. Chevron Style
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        chevronButton.tintColor = .systemGray3
    }

    func configure(title: String, subtitle: String, time: String, imageName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        timeLabel.text = time
        
        if let img = UIImage(named: imageName) {
            exerciseImageView.image = img
        } else {
            exerciseImageView.backgroundColor = .systemPink.withAlphaComponent(0.1)
        }
    }
}

*/
