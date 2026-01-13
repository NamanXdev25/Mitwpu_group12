import UIKit

final class MemoryImageCell: UICollectionViewCell {

    static let reuseIdentifier = "MemoryImageCell"

    @IBOutlet weak var imageView: UIImageView!

    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        onTap = nil
    }

    func configure(with image: UIImage) {
        imageView.image = image
    }

    @objc private func handleTap() {
        onTap?()
    }
}
