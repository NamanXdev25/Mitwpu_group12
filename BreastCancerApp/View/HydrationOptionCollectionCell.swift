import UIKit

final class HydrationOptionCollectionCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.cornerRadius = 0
        contentView.layer.maskedCorners = []
        dividerView.isHidden = false
    }

    func configure(
        text: String,
        hideDivider: Bool,
        isFirst: Bool,
        isLast: Bool
    ) {
        titleLabel.text = text
        dividerView.isHidden = hideDivider

        if isFirst || isLast {
            contentView.layer.cornerRadius = 16
            contentView.layer.maskedCorners = corners(
                isFirst: isFirst,
                isLast: isLast
            )
        }
    }

    private func corners(
        isFirst: Bool,
        isLast: Bool
    ) -> CACornerMask {

        var masked: CACornerMask = []

        if isFirst {
            masked.insert(.layerMinXMinYCorner)
            masked.insert(.layerMaxXMinYCorner)
        }

        if isLast {
            masked.insert(.layerMinXMaxYCorner)
            masked.insert(.layerMaxXMaxYCorner)
        }

        return masked
    }
}
