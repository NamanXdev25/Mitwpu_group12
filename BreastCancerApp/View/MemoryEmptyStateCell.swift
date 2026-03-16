import UIKit

final class MemoryEmptyStateCell: UICollectionViewCell {

    static let reuseIdentifier = "MemoryEmptyStateCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
    }
}
