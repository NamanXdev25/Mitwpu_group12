import UIKit

class ExerciseExploreCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style: White square with shadow
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        // Center Text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .darkGray
        
        // Center Icon
        iconImageView.contentMode = .center // Important for SF Symbols to look sharp
        iconImageView.tintColor = UIColor(red: 0.8, green: 0.4, blue: 0.5, alpha: 1.0) // Default Pink Tint
    }

    func setup(title: String, imageName: String) {
        titleLabel.text = title
        
        // 1. Try to load as a System SF Symbol first
        // We make it "Large" and "Bold" using configuration
        let config = UIImage.SymbolConfiguration(pointSize: 45, weight: .regular, scale: .default)
        
        if let sysImg = UIImage(systemName: imageName, withConfiguration: config) {
            iconImageView.image = sysImg
        }
        // 2. Fallback: Try to load from Assets (if you mix custom icons)
        else if let assetImg = UIImage(named: imageName) {
            iconImageView.image = assetImg
            iconImageView.contentMode = .scaleAspectFit // Asset images usually need scaling
        }
        // 3. Ultimate Fallback
        else {
            iconImageView.backgroundColor = .systemYellow.withAlphaComponent(0.2)
        }
    }
}
