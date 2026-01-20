import UIKit

final class GlassOptionCell: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dividerView: UIView!

    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func configure(text: String, hideDivider: Bool) {
        titleLabel.text = text
        dividerView.isHidden = hideDivider
    }

    // MARK: - Private

    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    @objc private func handleTap() {
        onTap?()
    }
}
    