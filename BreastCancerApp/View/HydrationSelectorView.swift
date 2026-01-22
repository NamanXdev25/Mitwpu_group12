import UIKit

final class HydrationSelectorView: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        titleLabel.textColor = isSelected ? .white : .black
        contentView.backgroundColor = isSelected ? .systemPink : .clear
        contentView.layer.cornerRadius = 12
    }
}
