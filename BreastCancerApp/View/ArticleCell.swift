import UIKit

class ArticleCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var articleImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    private var subtitleBottomConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true

        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.adjustsFontSizeToFitWidth = false
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.alpha = 1.0
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)

        containerView.clipsToBounds = true

        if subtitleBottomConstraint == nil {
            let constraint = subtitleLabel.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -16
            )
            constraint.priority = .required
            constraint.isActive = true
            subtitleBottomConstraint = constraint
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let maxWidth = containerView.bounds.width - 32
        titleLabel.preferredMaxLayoutWidth = maxWidth
        subtitleLabel.preferredMaxLayoutWidth = maxWidth
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let targetSize = CGSize(
            width: layoutAttributes.size.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        var updatedFrame = layoutAttributes.frame
        updatedFrame.size.height = ceil(size.height)
        layoutAttributes.frame = updatedFrame
        return layoutAttributes
    }

    func configure(with model: ArticleModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        subtitleLabel.alpha = 1.0
        articleImageView.image = UIImage(named: model.imageName)
    }
}
