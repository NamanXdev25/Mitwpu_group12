import UIKit

final class HealthStatusCell: UICollectionViewCell {

    static let reuseIdentifier = "HealthStatusCell"

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    // MARK: - UI Setup
    private func configureUI() {

        // Background
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        // Title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        // Chevron
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .systemGray3
        chevronImageView.contentMode = .scaleAspectFit

        // Accessibility
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    // MARK: - Configure
    func configure(title: String) {
        titleLabel.text = title
        accessibilityLabel = title
    }
}
