import UIKit

final class EmptyStateCell: UICollectionViewCell {

    static let reuseIdentifier = "EmptyStateCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
