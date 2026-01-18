import UIKit

final class ProfileHeaderCell: UICollectionViewCell {

    // MARK: - Reuse
    static let reuseIdentifier = "ProfileHeaderCell"

    // MARK: - Outlets
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    // MARK: - Constants
    private enum Layout {
        static let imageCornerRadius: CGFloat = 36
        static let nameFontSize: CGFloat = 20
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        profileImageView.image = nil
    }

    // MARK: - Configuration
    func configure(name: String, image: UIImage?) {
        nameLabel.text = name
        profileImageView.image = image ?? UIImage(systemName: "person.crop.circle.fill")
    }

    // MARK: - UI Setup
    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupProfileImageView()
        setupNameLabel()
    }

    private func setupProfileImageView() {
        profileImageView.layer.cornerRadius = Layout.imageCornerRadius
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    private func setupNameLabel() {
        nameLabel.font = UIFont.systemFont(
            ofSize: Layout.nameFontSize,
            weight: .semibold
        )
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
    }
}
