
import UIKit

class ArticleHeaderCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    func configure(imageName: String) {
        imageView.image = UIImage(named: imageName)
    }
}
