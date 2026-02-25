import UIKit

class HomeTitleCell: UICollectionViewCell {

    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var ProfileView: UIView!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var ProfileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Configure
    func configure(title: String, profileImage: UIImage? = nil) {
        HomeLabel.text = title
        
        // Set profile image if provided, otherwise use a system placeholder or default
        if let image = profileImage {
            ProfileImageView.image = image
        } else {
            // Use a system person circle image as fallback
            ProfileImageView.image = UIImage(systemName: "person.circle.fill")
            ProfileImageView.tintColor = .systemGray3
        }
        
        // Make profile image circular
        ProfileImageView.layer.cornerRadius = ProfileImageView.frame.width / 2
        ProfileImageView.clipsToBounds = true
        ProfileImageView.contentMode = .scaleAspectFill
    }
}
