import UIKit

// MARK: - Delegate Protocol
protocol CareHeaderCellDelegate: AnyObject {
    func careHeaderCellDidTapManage(_ cell: CareHeaderCell)
}

class CareHeaderCell: UICollectionViewCell {

    @IBOutlet weak var Titlelabel: UILabel!
    @IBOutlet weak var Managelabel: UILabel!
    
    weak var delegate: CareHeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Titlelabel.text = ""
        Managelabel.text = "Manage"
        
        // Make the Manage label tappable
        Managelabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(manageLabelTapped))
        Managelabel.addGestureRecognizer(tapGesture)
    }

    func configure(title: String, showManage: Bool) {
        Titlelabel.text = title
        Managelabel.isHidden = !showManage
    }
    
    @objc private func manageLabelTapped() {
        delegate?.careHeaderCellDidTapManage(self)
    }
}
