import UIKit

class CareMedicationCell: UICollectionViewCell {

    @IBOutlet weak var MedicationConatiner: UIView!
    @IBOutlet weak var MedicationImage: UIImageView!
    @IBOutlet weak var MedicationLabel: UILabel!
    @IBOutlet weak var TakenLabel: UILabel!
    @IBOutlet weak var MedicationInfoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Styling the container - we'll keep it simple as you'll set radius in Storyboard
        self.contentView.layer.masksToBounds = true
    }

    func configure(title: String, status: String, image: UIImage?) {
        MedicationLabel.text = title
        TakenLabel.text = status
        MedicationImage.image = image
    }
}
