import UIKit

class ArticleImageCell: UICollectionViewCell {

    @IBOutlet weak var articleImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        articleImageView.contentMode = .scaleAspectFit
        articleImageView.clipsToBounds = true
        articleImageView.layer.cornerRadius = 12
    }

    func configure(imageName: String) {
        articleImageView.image = UIImage(named: imageName)
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let width = layoutAttributes.frame.width
        let height = width * (9.0 / 16.0)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
