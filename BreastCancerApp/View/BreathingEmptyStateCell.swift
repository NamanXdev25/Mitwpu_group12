import UIKit

class BreathingEmptyStateCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
