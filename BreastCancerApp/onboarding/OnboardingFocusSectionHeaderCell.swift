import UIKit

class OnboardingFocusSectionHeaderCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!

    func configure(title: String) {
        titleLabel.text = title
    }
}
