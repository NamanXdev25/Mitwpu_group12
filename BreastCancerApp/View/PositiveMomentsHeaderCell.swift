import UIKit

class PositiveMomentsHeaderCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var manageButton: UIButton!

    var onManageTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        manageButton.addTarget(self, action: #selector(handleManageTap), for: .touchUpInside)
    }

    @objc private func handleManageTap() {
        onManageTap?()
    }
}
