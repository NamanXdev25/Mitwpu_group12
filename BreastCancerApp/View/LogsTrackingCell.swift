
import UIKit

class LogsTrackingCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: HealthTrackingModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.displayLastTracked
        iconImageView.image = UIImage(systemName: model.iconName)
    }
}
