
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
    }
    
    // MARK: - Configuration
    func configure(with feature: OnboardingFeature) {
        featureLabel.text = feature.title
        iconImageView.image = UIImage(systemName: feature.iconName)
    }
}

// MARK: - OnboardingFeature Content
extension OnboardingFeature {
    static let mindfulnessFeatures: [OnboardingFeature] = [
        OnboardingFeature(
            title: "Get mood-based suggestions",
            iconName: "face.smiling",
        ),
        OnboardingFeature(
            title: "Journal your thoughts",
            iconName: "book.closed",
        ),
        OnboardingFeature(
            title: "Breathing Exercises",
            iconName: "wind",
        )
    ]
    
    static let healthFeatures: [OnboardingFeature] = [
        OnboardingFeature(
            title: "Manage appointments and medicines",
            iconName: "calendar",
        ),
        OnboardingFeature(
            title: "Log exercise",
            iconName: "figure.cooldown",
        ),
        OnboardingFeature(
            title: "Monitor hydration",
            iconName: "drop",
        )
    ]
    
    static let gardenFeatures: [OnboardingFeature] = [
        OnboardingFeature(
            title: "Complete daily goals to earn coins",
            iconName: "checkmark.circle",
        ),
        OnboardingFeature(
            title: "Grow your garden",
            iconName: "camera.macro",
        )
    ]
}
