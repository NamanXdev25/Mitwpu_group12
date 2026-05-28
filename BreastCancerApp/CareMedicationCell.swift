import UIKit

// MARK: - Delegate Protocol

protocol CareMedicationCellDelegate: AnyObject {
    func careMedicationCellDidTap(_ cell: CareMedicationCell)
}

class CareMedicationCell: UICollectionViewCell {
    @IBOutlet var MedicationConatiner: UIView!
    @IBOutlet var MedicationImage: UIImageView!
    @IBOutlet var MedicationLabel: UILabel!
    @IBOutlet var TakenLabel: UILabel!
    @IBOutlet var MedicationInfoButton: UIButton!

    weak var delegate: CareMedicationCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.masksToBounds = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }

    @objc private func cellTapped() {
        delegate?.careMedicationCellDidTap(self)
    }

    func configure(title: String, status: String, image: UIImage?) {
        MedicationLabel.text = title
        TakenLabel.text = status
        MedicationImage.image = image
    }
}
