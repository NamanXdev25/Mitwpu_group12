import UIKit

class GardenItemCell: UICollectionViewCell {
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        itemImageView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 9, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center

        separatorView.backgroundColor = UIColor.systemGray5
    }

    func configure(with item: StoreItem, isLast: Bool) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.name

        separatorView.isHidden = isLast
    }
}
