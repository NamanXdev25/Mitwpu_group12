import UIKit

final class MemoryImageCell: UICollectionViewCell {

    static let reuseIdentifier = "MemoryImageCell"

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with image: UIImage) {
        imageView.image = image
    }
}
