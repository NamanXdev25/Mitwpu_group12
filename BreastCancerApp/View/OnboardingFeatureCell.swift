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
//            backgroundColor: UIColor(named: "pastel_pink")!
        ),
        OnboardingFeature(
            title: "Journal your thoughts",
            iconName: "book.closed",
//            iconTintColor: UIColor(named: "ArticlesPrimaryColor") ?? .systemPink,
//            backgroundColor: UIColor(named: "pastel_pink")!
        ),
        OnboardingFeature(
            title: "Breathing Exercises",
            iconName: "wind",
//            iconTintColor: UIColor(named: "ArticlesPrimaryColor") ?? .systemPink,
//            backgroundColor: UIColor(named: "pastel_pink")!
        )
    ]
    
    static let healthFeatures: [OnboardingFeature] = [
        OnboardingFeature(
            title: "Track appointments",
            iconName: "calendar",
//            iconTintColor: .systemTeal,
//            backgroundColor: UIColor(named: "pastel_blue")!
        ),
        OnboardingFeature(
            title: "Log exercise",
            iconName: "figure.cooldown",
//            iconTintColor: .systemTeal,
//            backgroundColor: UIColor(named: "pastel_blue")!
        ),
        OnboardingFeature(
            title: "Monitor hydration",
            iconName: "drop",
//            iconTintColor: .systemTeal,
//            backgroundColor: UIColor(named: "pastel_blue")!
        ),
        OnboardingFeature(
            title: "Manage medications",
            iconName: "pills",
//            iconTintColor: .systemTeal,
//            backgroundColor: UIColor(named: "pastel_blue")!
        )
    ]
    
    static let gardenFeatures: [OnboardingFeature] = [
        OnboardingFeature(
            title: "Complete daily goals to earn coins",
            iconName: "checkmark.circle",
//            iconTintColor: UIColor(named: "ArticlesPrimaryColor") ?? .systemPink,
//            backgroundColor: UIColor(named: "pastel_green")!
        ),
        OnboardingFeature(
            title: "Grow your garden",
            iconName: "camera.macro",
//            iconTintColor: UIColor(named: "ArticlesPrimaryColor") ?? .systemPink,
//            backgroundColor: UIColor(named: "pastel_green")!
        )
    ]
}
