import UIKit

class JournalActionCell: UICollectionViewCell {
    static let reuseIdentifier = "JournalActionCell"

    var didTap: (() -> Void)?

    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var chevronView: UIImageView!

    func configure(title: String, subtitle: String, icon: UIImage) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconView.image = icon
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        didTap?()
    }

    @IBAction func buttonTapped(_: UIButton) {
        didTap?()
    }
}
