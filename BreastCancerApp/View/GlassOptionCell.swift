import UIKit

class GlassOptionCell: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!

    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    func configure(text: String, hideDivider: Bool) {
        titleLabel.text = text
        dividerView.isHidden = hideDivider
    }

    @objc private func handleTap() {
        onTap?()
    }
}
