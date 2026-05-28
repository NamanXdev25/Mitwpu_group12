import UIKit

class PositiveMomentsHeaderCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var manageButton: UIButton!

    var onManageTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        manageButton.addTarget(self, action: #selector(handleManageTap), for: .touchUpInside)
    }

    @objc private func handleManageTap() {
        onManageTap?()
    }
}
