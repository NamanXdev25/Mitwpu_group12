import UIKit

class OrSeparatorCollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true

        backgroundColor = .white
        contentView.backgroundColor = .white
    }
}
