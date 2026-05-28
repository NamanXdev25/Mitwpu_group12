import UIKit

class ProfileSetupFormCollectionViewCell: UICollectionViewCell {
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var firstNameContainerView: UIView!
    @IBOutlet var firstNameTextField: UITextField!

    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var lastNameContainerView: UIView!
    @IBOutlet var lastNameTextField: UITextField!

    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var genderContainerView: UIView!
    @IBOutlet var genderTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        styleContainer(firstNameContainerView)
        styleContainer(lastNameContainerView)
        styleContainer(genderContainerView)
    }

    private func styleContainer(_ view: UIView) {
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemPink.cgColor
    }
}
