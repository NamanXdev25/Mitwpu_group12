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
        
        checkmarkImageView.isHidden = !isCompleted
    }
}
