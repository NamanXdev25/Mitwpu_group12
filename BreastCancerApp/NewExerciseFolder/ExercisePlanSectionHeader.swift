import UIKit

class ExercisePlanSectionHeader: UICollectionReusableView {
    @IBOutlet var sectionTitleLabel: UILabel!

    func configure(with title: String) {
        sectionTitleLabel.text = title
    }
}
