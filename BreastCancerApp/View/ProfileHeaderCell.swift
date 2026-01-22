import UIKit

protocol ProfileHeaderCellDelegate: AnyObject {
    func didTapCamera()
}

final class ProfileHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "ProfileHeaderCell"

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var cameraButton: UIButton!

    weak var delegate: ProfileHeaderCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        cameraButton.layer.cornerRadius = 12
        cameraButton.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius =
            profileImageView.bounds.width / 2
    }

    func configure(name: String, image: UIImage?, isEditing: Bool = false) {
        nameLabel.text = name
        profileImageView.image =
            image ?? UIImage(systemName: "person.crop.circle.fill")
        cameraButton.isHidden = !isEditing
    }

    @IBAction private func cameraTapped(_ sender: UIButton) {
        delegate?.didTapCamera()
    }
}
