import UIKit

// MARK: - Delegate Protocol
protocol CareMedicationCellDelegate: AnyObject {
    func careMedicationCellDidTap(_ cell: CareMedicationCell)
}

class CareMedicationCell: UICollectionViewCell {

    @IBOutlet weak var MedicationConatiner: UIView!
    @IBOutlet weak var MedicationImage: UIImageView!
    @IBOutlet weak var MedicationLabel: UILabel!
    @IBOutlet weak var TakenLabel: UILabel!
    @IBOutlet weak var MedicationInfoButton: UIButton!
    
    weak var delegate: CareMedicationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = true
        
        // Add tap gesture to the entire cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        self.contentView.addGestureRecognizer(tapGesture)
        self.contentView.isUserInteractionEnabled = true
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
