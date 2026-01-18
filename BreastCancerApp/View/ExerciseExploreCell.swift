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
        
        let config = UIImage.SymbolConfiguration(pointSize: 45, weight: .regular, scale: .default)
        
        if let sysImg = UIImage(systemName: imageName, withConfiguration: config) {
            iconImageView.image = sysImg
        }

        else if let assetImg = UIImage(named: imageName) {
            iconImageView.image = assetImg
            iconImageView.contentMode = .scaleAspectFit
        }
        else {
            iconImageView.backgroundColor = .systemYellow.withAlphaComponent(0.2)
        }
    }
}
