import UIKit

class MenuOptionCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .white

        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .systemGray3
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
