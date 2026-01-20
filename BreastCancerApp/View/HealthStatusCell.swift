import UIKit

final class HealthStatusCell: UICollectionViewCell {

    static let reuseIdentifier = "HealthStatusCell"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .systemGray3
        chevronImageView.contentMode = .scaleAspectFit

        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        accessibilityLabel = nil
    }

    func configure(title: String) {
        titleLabel.text = title
        accessibilityLabel = title
    }
}
