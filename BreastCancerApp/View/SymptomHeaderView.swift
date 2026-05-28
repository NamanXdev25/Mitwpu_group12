import UIKit

class SymptomHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "header_cell"

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionButton: UIButton!

    var editTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        actionButton.isHidden = true
    }

    @IBAction func editButtonTapped(_: UIButton) {
        editTapped?()
    }

    func configure(title: String, showButton: Bool, buttonTitle: String = "Edit") {
        titleLabel.text = title
        actionButton.isHidden = !showButton
        actionButton.setTitle(buttonTitle, for: .normal)
    }
}
