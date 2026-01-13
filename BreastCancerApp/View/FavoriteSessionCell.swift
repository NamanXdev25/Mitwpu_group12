import UIKit

class FavoriteSessionCell: UICollectionViewCell {
    
    // --- OUTLETS ---
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var gradientContainerView: UIView?
    
    // --- MATERIAL DESIGN ELEMENTS ---
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    weak var delegate: SessionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMaterialGradient()
    }
    
    private func setupMaterialGradient() {
        guard let container = gradientContainerView else { return }
        container.backgroundColor = .clear
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        container.insertSubview(blurEffectView, at: 0)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: container.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(on: self)
    }
    
    func configureCell(session: BreathingSession) {
        sessionImageView.image = UIImage(named: session.imageName)
        titleLabel?.text = session.title
        categoryLabel?.text = session.category
        nameLabel?.text = session.title
        
        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)
        likeButton.tintColor = .systemPink
        
        if let image = sessionImageView.image {
            applyMaterialTheme(for: image)
        }
    }
    
    private func applyMaterialTheme(for image: UIImage) {
        guard let nameLabel = nameLabel, let container = gradientContainerView else { return }
        
        // This line will now work because of the extension below
        let isDark = image.isDark
        nameLabel.textColor = isDark ? .white : .black
        blurEffectView.effect = isDark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
        
        // Material tint #E86A92
        container.backgroundColor = UIColor(red: 232/255, green: 106/255, blue: 146/255, alpha: 0.15)
    }
}

// MARK: - Helper Extension (Fixes 'isDark' error)
extension UIImage {
    var isDark: Bool {
        guard let cgImage = self.cgImage else { return false }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer { data.deallocate() }
        
        let context = CGContext(data: data, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 1, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        return data.pointee < 128
    }
}
