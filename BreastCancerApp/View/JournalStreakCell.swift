import UIKit

class JournalStreakCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var daysLabel: UILabel!
    @IBOutlet var flameImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var inactiveLabel: UILabel!

    static let reuseIdentifier = "JournalStreakCell"

    func configure(streak: Int) {
        if streak == 0 {
            titleLabel.isHidden = true
            countLabel.isHidden = true
            daysLabel.isHidden = true
            flameImageView.isHidden = true
            inactiveLabel.isHidden = false
        } else {
            countLabel.text = "\(streak)"
            titleLabel.isHidden = false
            countLabel.isHidden = false
            daysLabel.isHidden = false
            flameImageView.isHidden = false
            inactiveLabel.isHidden = true
        }
    }
}
