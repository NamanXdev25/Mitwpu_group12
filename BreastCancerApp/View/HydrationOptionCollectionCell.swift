import UIKit

final class HydrationOptionCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dividerView: UIView!

    func configure(text: String, hideDivider: Bool, isFirst: Bool, isLast: Bool) {
        titleLabel.text = text
        dividerView.isHidden = hideDivider

        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .white
    }
}
