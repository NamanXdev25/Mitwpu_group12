import UIKit

class ArticleContentCell: UICollectionViewCell {

    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.numberOfLines = 0
    }

    func configure(title: String, content: String) {
        contentLabel.attributedText = nil
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        setNeedsLayout()
        layoutIfNeeded()
    }

    func configureAttributed(text: NSAttributedString) {
        contentLabel.text = nil
        contentLabel.attributedText = text
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
