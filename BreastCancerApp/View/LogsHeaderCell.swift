import UIKit

class LogsHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBottomGradient()
    }

    func configure(with model: HeaderModel) {
        titleLabel.text = model.title
        dateLabel.text = model.date
    }
    
    private func addBottomGradient() {
        // Remove existing gradient if any
        gradientLayer?.removeFromSuperlayer()
        
        // Create a gradient layer
        let gradient = CAGradientLayer()
        
        // Colors: Clear (top) -> White (bottom)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.cgColor
        ]
        
        // Locations: Start fading earlier for better coverage
        gradient.locations = [0.0, 0.60, 0.95]
        
        // Add to the cell's layer (not image view) so it can extend beyond
        contentView.layer.addSublayer(gradient)
        self.gradientLayer = gradient
        
        // Send it behind everything except the background image
        if let imageView = backgroundImageView {
            contentView.layer.insertSublayer(gradient, above: imageView.layer)
        }
    }
    
    // Ensure gradient resizes with the cell
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Position gradient to cover the full cell width and extend downward
        let gradientHeight: CGFloat = contentView.bounds.height + 50 // Extend 50pts beyond
        gradientLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width, // Full screen width
            height: gradientHeight
        )
    }
}
