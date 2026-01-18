import UIKit

final class HealthStatusCell: UICollectionViewCell {

    // MARK: - Reuse
    static let reuseIdentifier = "HealthStatusCell"

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!

    // MARK: - Constants
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let titleFontSize: CGFloat = 16
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        accessibilityLabel = nil
    }

    // MARK: - Configuration
    func configure(title: String) {
        titleLabel.text = title
        accessibilityLabel = title
    }

    // MARK: - UI Setup
    private func configureUI() {
        setupBackground()
        setupTitleLabel()
        setupChevron()
        setupAccessibility()
    }

    private func setupBackground() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true
    }

    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(
            ofSize: Layout.titleFontSize,
            weight: .regular
        )
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
    }

    private func setupChevron() {
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .systemGray3
        chevronImageView.contentMode = .scaleAspectFit
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
}
