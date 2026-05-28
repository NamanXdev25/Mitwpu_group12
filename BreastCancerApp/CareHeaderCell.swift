import UIKit

// MARK: - Delegate Protocol

protocol CareHeaderCellDelegate: AnyObject {
    func careHeaderCellDidTapManage(_ cell: CareHeaderCell)
}

class CareHeaderCell: UICollectionViewCell {
    @IBOutlet var Titlelabel: UILabel!
    @IBOutlet var Managelabel: UILabel!

    weak var delegate: CareHeaderCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        Titlelabel.text = ""
        Managelabel.text = "Manage"

        Managelabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(manageLabelTapped))
        Managelabel.addGestureRecognizer(tapGesture)
    }

    func configure(title: String, showManage: Bool, actionTitle: String = "Manage") {
        Titlelabel.text = title
        Managelabel.text = actionTitle
        Managelabel.isHidden = !showManage
    }

    @objc private func manageLabelTapped() {
        delegate?.careHeaderCellDidTapManage(self)
    }
}
