import UIKit

class FilterCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!

    func configure(text: String, isSelected: Bool) {
        titleLabel.text = text

        if isSelected {
            containerView.backgroundColor = UIColor(named: "primary_color")
            titleLabel.textColor = .white
        } else {
            containerView.backgroundColor = UIColor(named: "filter_buttons")
            titleLabel.textColor = .darkGray
        }
    }
}
