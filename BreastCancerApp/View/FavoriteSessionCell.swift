import UIKit

class FavoriteSessionCell: UICollectionViewCell {
    @IBOutlet var sessionImageView: UIImageView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var gradientContainerView: UIView?

    private let materialBlur = FadingMaterialView(effect: UIBlurEffect(style: .light))

    weak var delegate: SessionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMaterialGradient()
    }

    private func setupMaterialGradient() {
        guard let container = gradientContainerView else { return }

        container.backgroundColor = .clear
        materialBlur.translatesAutoresizingMaskIntoConstraints = false
        container.insertSubview(materialBlur, at: 0)

        materialBlur.alpha = 0.87

        NSLayoutConstraint.activate([
            materialBlur.topAnchor.constraint(equalTo: container.topAnchor),
            materialBlur.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            materialBlur.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            materialBlur.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }

    func configureCell(session: BreathingSession) {
        sessionImageView.image = UIImage(named: session.imageName)

        categoryLabel?.text = session.category
        nameLabel?.text = session.title

        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)

        if let image = sessionImageView.image {
            let isDark = image.isDark
            nameLabel?.textColor = isDark ? .white : .black
            materialBlur.effect = isDark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
        }
    }

    @IBAction func likeButtonTapped(_: UIButton) {
        delegate?.didTapLikeButton(on: self)
    }
}

// MARK: - Fading Material View (Pure UIKit approach)

final class FadingMaterialView: UIVisualEffectView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CAGradientLayer()
        maskLayer.frame = bounds
        maskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]

        maskLayer.locations = [0.3, 1.0]
        layer.mask = maskLayer
    }
}

// MARK: - Helper Extension

extension UIImage {
    var isDark: Bool {
        guard let cgImage = cgImage else { return false }
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer { data.deallocate() }
        let context = CGContext(
            data: data,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 1,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return data.pointee < 128
    }
}
