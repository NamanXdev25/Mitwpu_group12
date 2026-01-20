import UIKit

final class GlassOptionCell: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!

    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    func configure(text: String, hideDivider: Bool) {
        titleLabel.text = text
        dividerView.isHidden = hideDivider
    }

    @objc private func handleTap() {
        onTap?()
    }
}
