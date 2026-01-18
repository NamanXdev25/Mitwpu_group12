import UIKit

final class NotificationsHeaderCell: UICollectionViewCell {

    // MARK: - Reuse
    static let reuseIdentifier = "NotificationsHeaderCell"

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    // MARK: - Configuration
    func configure(title: String) {
        titleLabel.text = title
    }
}
