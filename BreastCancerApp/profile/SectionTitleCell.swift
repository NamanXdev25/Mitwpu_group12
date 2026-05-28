import UIKit

class SectionTitleCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "Notifications"
    }
}
