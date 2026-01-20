import UIKit

final class AddMemoryOptionCell: UICollectionViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label

        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
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
