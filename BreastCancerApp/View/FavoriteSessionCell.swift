import UIKit
class FavoriteSessionCell: UICollectionViewCell {
    
    // --- OLD OUTLETS (Keep these safely connected) ---
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var heartContainerView: UIView!
    
    // --- NEW OUTLETS (Changed to '?' to prevent crashing) ---
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var gradientContainerView: UIView?
    
    // --- VARIABLES ---
    weak var delegate: SessionCellDelegate?
    private let gradientLayer = CAGradientLayer()
    
    // --- LIFECYCLE ---
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Safely update gradient frame if the view exists
        if let container = gradientContainerView {
            gradientLayer.frame = container.bounds
        }
    }
    
    // --- SETUP ---
    private func setupGradient() {
        // Only add gradient if the container exists
        if let container = gradientContainerView {
            container.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    // --- ACTIONS ---
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(on: self)
    }
    
    // --- CONFIGURATION ---
    func configureCell(session: BreathingSession) {
        
        // 1. Basic Setup
        sessionImageView.image = UIImage(named: session.imageName)
        
        // 2. Set Text (Handle both Old and New Labels safely)
        titleLabel?.text = session.title       // Old Design
        categoryLabel?.text = session.category // Old Design
        nameLabel?.text = session.title        // New Design (Safe)
        
        // 3. Heart Button Logic
        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)
        likeButton.tintColor = .systemPink
        
        // 4. Run Smart Gradient Logic (Only if image exists)
        if let image = sessionImageView.image {
            applyAdaptiveTheme(for: image)
        }
    }
    
    // --- SMART THEME LOGIC ---
    private func applyAdaptiveTheme(for image: UIImage) {
        // Guard checks to prevent crashing
        guard let nameLabel = nameLabel, let _ = gradientContainerView else { return }
        
        let isDark = image.isDark
        
        // 1. Set Text Color
        nameLabel.textColor = isDark ? .white : .black
        
        // 2. Set Gradient Colors
        let baseColor = isDark ? UIColor.black : UIColor.white
        
        // CHANGE HERE: Lower the alpha values so the image shows through
        gradientLayer.colors = [
            baseColor.withAlphaComponent(0.0).cgColor, // Top: Completely Clear
            baseColor.withAlphaComponent(0.4).cgColor, // Middle: Very subtle fade
            baseColor.withAlphaComponent(0.88).cgColor // Bottom: 85% opacity (Not 100% solid!)
        ]
        
        // Optional: Adjust the gradient locations to push the color lower down
        gradientLayer.locations = [0.0, 0.6, 1.0]
    }
}

// PASTE AT THE BOTTOM OF FavoriteSessionCell.swift

extension UIImage {
    var isDark: Bool {
        guard let cgImage = self.cgImage else { return false }
        guard let imageData = cgImage.dataProvider?.data else { return false }
        guard let ptr = CFDataGetBytePtr(imageData) else { return false }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow
        
        var totalLuminance: CGFloat = 0
        var pixelCount: CGFloat = 0
        
        for x in stride(from: 0, to: width, by: 100) {
            for y in stride(from: 0, to: height, by: 100) {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let r = ptr[offset]
                let g = ptr[offset + 1]
                let b = ptr[offset + 2]
                
                let luminance = (0.299 * CGFloat(r) + 0.587 * CGFloat(g) + 0.114 * CGFloat(b))
                totalLuminance += luminance
                pixelCount += 1
            }
        }
        
        return (totalLuminance / pixelCount) < 128
    }
}
