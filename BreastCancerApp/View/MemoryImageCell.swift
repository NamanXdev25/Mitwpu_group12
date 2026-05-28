import UIKit

final class MemoryImageCell: UICollectionViewCell {
    static let reuseIdentifier = "MemoryImageCell"

    @IBOutlet private var imageView: UIImageView!

    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureImageView()
        configureGesture()
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

// MARK: - Private Configuration

private extension MemoryImageCell {
    func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
    }

    func configureGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapGesture)
    }
}
