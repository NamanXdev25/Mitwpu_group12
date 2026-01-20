import UIKit

final class NotificationsHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "NotificationsHeaderCell"

    @IBOutlet private weak var titleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
