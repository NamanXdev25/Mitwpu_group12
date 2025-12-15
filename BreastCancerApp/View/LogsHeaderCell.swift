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
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.cgColor
        ]
        gradient.locations = [0.0, 0.65, 1.0]
        
        contentView.layer.addSublayer(gradient)
        self.gradientLayer = gradient
        
        if let imageView = backgroundImageView {
            contentView.layer.insertSublayer(gradient, above: imageView.layer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientHeight: CGFloat = contentView.bounds.height + 50
        gradientLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width,
            height: gradientHeight
        )
    }
}
