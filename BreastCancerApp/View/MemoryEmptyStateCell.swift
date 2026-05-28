import UIKit

final class MemoryEmptyStateCell: UICollectionViewCell {
    static let reuseIdentifier = "MemoryEmptyStateCell"

    @IBOutlet var containerView: UIView!
    @IBOutlet var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
    }
}
