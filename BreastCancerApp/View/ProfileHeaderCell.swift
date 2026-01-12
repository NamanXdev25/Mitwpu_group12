import UIKit

final class ProfileHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "ProfileHeaderCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        profileImageView.layer.cornerRadius = 36
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
    }

    func configure(name: String, image: UIImage?) {
        nameLabel.text = name
        profileImageView.image = image ?? UIImage(systemName: "person.crop.circle.fill")
    }
}
