import UIKit

class ProfileSetupPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        styleCameraButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensures perfect circle after AutoLayout
        cameraButton.layer.cornerRadius = cameraButton.bounds.height / 2
    }

    private func styleCameraButton() {
       
        cameraButton.backgroundColor = UIColor.systemPink

        cameraButton.tintColor = .white
        cameraButton.layer.borderWidth = 2
        cameraButton.layer.borderColor = UIColor.white.cgColor

        cameraButton.clipsToBounds = true
        cameraButton.layer.shadowOpacity = 0
    }
}
