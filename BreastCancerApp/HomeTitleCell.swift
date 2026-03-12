import UIKit

class HomeTitleCell: UICollectionViewCell {

    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var ProfileView: UIView!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var ProfileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
