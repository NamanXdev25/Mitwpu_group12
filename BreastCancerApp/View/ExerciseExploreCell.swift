import UIKit

class ExerciseExploreCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
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
