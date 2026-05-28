import UIKit

class ArticleLinkCell: UICollectionViewCell {
    @IBOutlet var sourceLabel: UILabel!
    @IBOutlet var linkButton: UIButton!

    private var urlString: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        linkButton.setTitleColor(.systemBlue, for: .normal)
        linkButton.titleLabel?.font = .systemFont(ofSize: 15)
        linkButton.titleLabel?.numberOfLines = 0
        linkButton.contentHorizontalAlignment = .left
    }

    func configure(urlString: String) {
        self.urlString = urlString
        sourceLabel.text = "Content adapted from educational resources provided by leading cancer research and healthcare "
            + "organizations, including the American Cancer Society, the National Cancer Institute, and the Susan G. Komen Foundation."
        linkButton.setTitle(urlString, for: .normal)
    }

    @IBAction func linkTapped(_: UIButton) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
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
