import UIKit

class HomeTodaysGoalCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var chevronButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String, points: String, imageName: String, isCompleted: Bool = false) {
        titleLabel.text = title
        pointsLabel.text = points
        
        iconImageView.image = UIImage(named: imageName)
        
        // Show checkmark only when completed
        checkmarkImageView.isHidden = !isCompleted
        
        // Hide chevron when completed, show when not completed
        chevronButton.isHidden = isCompleted
        
        if isCompleted {
            // Gray out the card when completed
            containerView.alpha = 0.5
            titleLabel.alpha = 0.6
            pointsLabel.alpha = 0.6
            iconImageView.alpha = 0.6
        } else {
            // Normal appearance when not completed
            containerView.alpha = 1.0
            titleLabel.alpha = 1.0
            pointsLabel.alpha = 1.0
            iconImageView.alpha = 1.0
        }
    }
}
