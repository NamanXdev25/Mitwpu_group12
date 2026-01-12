import UIKit

final class NotificationsHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "NotificationsHeaderCell"

    @IBOutlet weak var titleLabel: UILabel!

    func configure(title: String) {
        titleLabel.text = title
    }
}
