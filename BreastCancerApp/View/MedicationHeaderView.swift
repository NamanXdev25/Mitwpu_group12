import UIKit

class MedicationHeaderView: UICollectionReusableView {
    static let reuseIdentifier: String = "med_header"

    @IBOutlet var titleLabel: UILabel!

    func configure(with text: String) {
        titleLabel.text = text
    }
}
