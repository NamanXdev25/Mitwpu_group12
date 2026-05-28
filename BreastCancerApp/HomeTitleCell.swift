import UIKit

class HomeTitleCell: UICollectionViewCell {
    @IBOutlet var HomeLabel: UILabel!
    @IBOutlet var ProfileView: UIView!
    @IBOutlet var ProfileImageView: UIImageView!
    @IBOutlet var ProfileButton: UIButton!

    // MARK: - Configure

    func configure(title: String, profileImage: UIImage? = nil) {
        HomeLabel.text = title

        if let image = profileImage {
            ProfileImageView.image = image
        } else {
            ProfileImageView.image = UIImage(systemName: "person.circle.fill")
            ProfileImageView.tintColor = .systemGray3
        }

        ProfileImageView.layer.cornerRadius = ProfileImageView.frame.width / 2
        ProfileImageView.clipsToBounds = true
        ProfileImageView.contentMode = .scaleAspectFill
    }
}
