import UIKit

class ArticleCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: ArticleModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        articleImageView.image = UIImage(named: model.imageName)
    }
}
