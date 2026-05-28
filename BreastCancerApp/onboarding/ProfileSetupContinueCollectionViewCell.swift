import UIKit

class ProfileSetupContinueCollectionViewCell: UICollectionViewCell {
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var footerLabel: UILabel!

    var onContinueTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        continueButton.backgroundColor = UIColor.systemPink
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 26
        continueButton.clipsToBounds = true

        footerLabel.textColor = UIColor.lightGray
        footerLabel.textAlignment = .center
    }

    @IBAction func continueTapped(_: UIButton) {
        onContinueTapped?()
    }
}
