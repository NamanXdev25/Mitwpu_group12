import UIKit

class JournalSectionHeaderView: UICollectionReusableView {
    var seeAllTapped: (() -> Void)?

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionButton: UIButton!

    static let reuseIdentifier = "header_cell"

    override func awakeFromNib() {
        super.awakeFromNib()

        actionButton.isHidden = true
    }

    @IBAction func seeAllButtonTapped(_: UIButton) {
        seeAllTapped?()
    }

    func configure(title: String, showButton: Bool, buttonTitle: String = "See All") {
        titleLabel.text = title
        actionButton.isHidden = !showButton
        actionButton.setTitle(buttonTitle, for: .normal)
    }
}
