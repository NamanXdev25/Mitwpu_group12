import UIKit

final class AddMemoryOptionCell: UICollectionViewCell {
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureIconImageView()
        configureTitleLabel()
        configureLayout()
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

    func configureLayout() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let removableConstraints = constraints.filter { constraint in
            let firstItem = constraint.firstItem as AnyObject?
            let secondItem = constraint.secondItem as AnyObject?
            return firstItem === iconImageView ||
                secondItem === iconImageView ||
                firstItem === titleLabel ||
                secondItem === titleLabel
        }

        NSLayoutConstraint.deactivate(removableConstraints)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
