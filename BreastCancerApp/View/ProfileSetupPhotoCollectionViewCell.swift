import UIKit

protocol ProfileSetupPhotoCellDelegate: AnyObject {
    func didTapCameraButton()
}

class ProfileSetupPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!

    weak var delegate: ProfileSetupPhotoCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        cameraButton.backgroundColor = .systemPink
        cameraButton.tintColor = .white
        cameraButton.layer.borderWidth = 2
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraButton.layer.cornerRadius = cameraButton.bounds.height / 2
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }

    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        delegate?.didTapCameraButton()
    }

    func setProfileImage(_ image: UIImage) {
        profileImageView.image = image
    }
}
