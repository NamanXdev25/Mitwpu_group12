import UIKit

final class ProfileHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "ProfileHeaderCell"

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        profileImageView.layer.cornerRadius = 36
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        profileImageView.image = nil
    }

    func configure(name: String, image: UIImage?) {
        nameLabel.text = name
        profileImageView.image = image ?? UIImage(systemName: "person.crop.circle.fill")
    }
}
