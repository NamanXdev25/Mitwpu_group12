import UIKit

class StoreItemCell: UICollectionViewCell {
    @IBOutlet var cardContainerView: UIView!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var coinImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false

        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 13
        cardContainerView.layer.masksToBounds = true

        itemImageView.contentMode = .scaleAspectFit

        priceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        priceLabel.textColor = .label
        priceLabel.numberOfLines = 2
        priceLabel.textAlignment = .center
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.7
    }

    // MARK: - Standard configure (shop tabs: Nature / Wellness)

    func configure(with item: StoreItem, showPrice: Bool) {
        itemImageView.image = UIImage(named: item.imageName)

        if showPrice {
            coinImageView.isHidden = false
            priceLabel.isHidden = false
            priceLabel.text = "\(item.price)"
        } else {
            coinImageView.isHidden = true
            priceLabel.isHidden = false
            priceLabel.text = item.name
        }

        resetBaseStyle()
    }

    // MARK: - Your Items configure (bases + unlocked items)

    func configureAsYourItem(_ item: StoreItem, isBase: Bool, isSelectedBase: Bool) {
        configure(with: item, showPrice: false)

        if isBase {
            cardContainerView.layer.borderWidth = isSelectedBase ? 3.0 : 1.5
            cardContainerView.layer.borderColor = isSelectedBase
                ? UIColor.systemGreen.cgColor
                : UIColor.systemGray3.cgColor

            if isSelectedBase {
                addActiveBadge()
            } else {
                removeActiveBadge()
            }
        } else {
            resetBaseStyle()
        }
    }

    // MARK: - Active badge ("✓ Active" shown on the selected base tile)

    private func addActiveBadge() {
        let tag = 9001
        guard contentView.viewWithTag(tag) == nil else { return }

        let badge = UILabel()
        badge.tag = tag
        badge.text = "✓ Active"
        badge.font = .systemFont(ofSize: 9, weight: .bold)
        badge.textColor = .white
        badge.backgroundColor = UIColor.systemGreen
        badge.textAlignment = .center
        badge.layer.cornerRadius = 6
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(badge)

        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            badge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            badge.heightAnchor.constraint(equalToConstant: 16),
            badge.widthAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func removeActiveBadge() {
        contentView.viewWithTag(9001)?.removeFromSuperview()
    }

    private func resetBaseStyle() {
        cardContainerView.layer.borderWidth = 0
        cardContainerView.layer.borderColor = nil
        removeActiveBadge()
    }
}
