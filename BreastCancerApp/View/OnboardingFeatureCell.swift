//
//  OnboardingFeatureCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 27/01/26.
//

import UIKit

class OnboardingFeatureCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var featureLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Optional: Add any additional styling here if needed
    }
    
    // MARK: - Configuration
    func configure(with feature: OnboardingFeature) {
        featureLabel.text = feature.title
        iconImageView.image = UIImage(systemName: feature.iconName)
//        iconImageView.tintColor = feature.iconTintColor
//        iconContainerView.backgroundColor = feature.backgroundColor
    }
}

// MARK: - OnboardingFeature Model
struct OnboardingFeature {
    let title: String
    let iconName: String
//    let iconTintColor: UIColor
//    let backgroundColor: UIColor
    
    static let mindfulnessFeatures: [OnboardingFeature] = [
        OnboardingFeature(
            title: "Get mood-based suggestions",
            iconName: "face.smiling",
//            iconTintColor: UIColor(named: "ArticlesPrimaryColor") ?? .systemPink,
//            backgroundColor: UIColor(red: 0.848, green: 0.691, blue: 0.768, alpha: 0.55)
        ),
        OnboardingFeature(
            title: "Journal your thoughts",
            iconName: "book.closed",
//            iconTintColor: UIColor(named: "ArticlesPrimaryColor") ?? .systemPink,
//            backgroundColor: UIColor(red: 0.848, green: 0.691, blue: 0.768, alpha: 0.55)
        ),
        OnboardingFeature(
            title: "Breathing Exercises",
            iconName: "wind",
//            iconTintColor: UIColor(named: "ArticlesPrimaryColor") ?? .systemPink,
//            backgroundColor: UIColor(red: 0.848, green: 0.691, blue: 0.768, alpha: 0.55)
        )
    ]
}
