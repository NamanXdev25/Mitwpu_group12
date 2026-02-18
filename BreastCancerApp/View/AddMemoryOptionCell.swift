import UIKit

final class AddMemoryOptionCell: UICollectionViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureIconImageView()
        configureTitleLabel()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
    }

    func configure(title: String, iconName: String) {
        titleLabel.text = title
        iconImageView.image = UIImage(named: iconName)
    }
}

// MARK: - Private Configuration
private extension AddMemoryOptionCell {

    func configureIconImageView() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
    }

    func configureTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
    }
}
