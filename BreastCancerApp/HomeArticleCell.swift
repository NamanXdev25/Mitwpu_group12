import UIKit

class HomeArticleCell: UICollectionViewCell {
    
    @IBOutlet weak var ArticleContainerView: UIView!
    @IBOutlet weak var ArticleImageView: UIImageView!
    @IBOutlet weak var ArticleTitleLable: UILabel!
    @IBOutlet weak var ArticleSubheadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with article: Article) {
                ArticleTitleLable.text = article.title
                ArticleSubheadLabel.text = article.subtitle
        
                // Set image with proper content mode
                ArticleImageView.image = UIImage(named: article.imageName)
//                ArticleImageView.contentMode = .scaleAspectFill
    }
}
