import UIKit

class HomeArticleCell: UICollectionViewCell {
    
    @IBOutlet weak var ArticleContainerView: UIView!
    @IBOutlet weak var ArticleImageView: UIImageView!
    @IBOutlet weak var ArticleTitleLable: UILabel!
    @IBOutlet weak var ArticleSubheadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        ArticleImageView.contentMode = .scaleAspectFill
        ArticleImageView.clipsToBounds = true

        // Force title to never clip
        ArticleTitleLable.numberOfLines = 0
        ArticleTitleLable.lineBreakMode = .byWordWrapping
        ArticleTitleLable.adjustsFontSizeToFitWidth = false

        // Ensure trailing constraint doesn't cut off — override in case XIB is wrong
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

        // Re-pin title and subtitle trailing to contentView with 16pt padding
        // in case the XIB constraint is clipping them
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
