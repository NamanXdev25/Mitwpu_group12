import UIKit

class HobbyCell: UICollectionViewCell {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        updateAppearance(isSelected: false)
    }

    func configure(with hobby: String, isSelected: Bool) {
        titleLabel.text = hobby
        updateAppearance(isSelected: isSelected)
    }

    private func updateAppearance(isSelected: Bool) {
        if isSelected {
            containerView.backgroundColor = UIColor(named: "OnboardingPrimaryColor")
            titleLabel.textColor = .white
        } else {
            containerView.backgroundColor = UIColor(named: "OnboardingBackgroundColor")
            titleLabel.textColor = .black
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let targetSize = CGSize(
            width: UIView.layoutFittingCompressedSize.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )

        var frame = layoutAttributes.frame
        frame.size.width = ceil(size.width)
        frame.size.height = 40
        layoutAttributes.frame = frame

        return layoutAttributes
    }
}
