import UIKit

class SymptomLogButtonCell: UICollectionViewCell {
    @IBOutlet var logButton: UIButton!

    var onButtonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        logButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        logButton.configuration?.baseBackgroundColor = UIColor(named: "SymptomsPrimaryColor")
    }

    func configure(isEnabled: Bool) {
        logButton.isEnabled = isEnabled
        logButton.alpha = isEnabled ? 1.0 : 0.5
    }

    @objc private func buttonTapped() {
        onButtonTapped?()
    }
}
