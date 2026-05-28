import UIKit

class MindfulnessExploreCell: UICollectionViewCell {
    var didTap: (() -> Void)?

    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var chevronView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tap)
    }

    @objc private func tapped() {
        didTap?()
    }

    func configure(title: String, subtitle: String, icon: UIImage) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconView.image = icon
    }
}
