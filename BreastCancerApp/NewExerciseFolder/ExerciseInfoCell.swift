import UIKit

class ExerciseInfoCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!

    var onInfoTap: ((_ infoButton: UIButton) -> Void)?

    func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }

    @IBAction func infoTapped(_ sender: Any) {
        if let btn = sender as? UIButton {
            onInfoTap?(btn)
        } else {
            onInfoTap?(infoButton)
        }
    }
}
