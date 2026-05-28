import UIKit

class HomeArticleCell: UICollectionViewCell {
    @IBOutlet var ArticleContainerView: UIView!
    @IBOutlet var ArticleImageView: UIImageView!
    @IBOutlet var ArticleTitleLable: UILabel!
    @IBOutlet var ArticleSubheadLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        ArticleImageView.contentMode = .scaleAspectFill
        ArticleImageView.clipsToBounds = true

        ArticleTitleLable.numberOfLines = 0
        ArticleTitleLable.lineBreakMode = .byWordWrapping
        ArticleTitleLable.adjustsFontSizeToFitWidth = false

        ArticleTitleLable.translatesAutoresizingMaskIntoConstraints = false
        ArticleTitleLable.setContentCompressionResistancePriority(.required, for: .vertical)
        ArticleTitleLable.setContentHuggingPriority(.defaultLow, for: .horizontal)

        ArticleSubheadLabel.numberOfLines = 0
        ArticleSubheadLabel.lineBreakMode = .byWordWrapping
        ArticleSubheadLabel.textColor = UIColor.secondaryLabel
        ArticleSubheadLabel.alpha = 1.0
        ArticleSubheadLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let maxWidth = contentView.bounds.width - 32
        ArticleTitleLable.preferredMaxLayoutWidth = maxWidth
        ArticleSubheadLabel.preferredMaxLayoutWidth = maxWidth
    }

    func configure(with article: Article) {
        ArticleTitleLable.text = article.title
        ArticleSubheadLabel.text = article.subtitle
        ArticleSubheadLabel.alpha = 1.0
        ArticleImageView.image = UIImage(named: article.imageName)
    }
}
