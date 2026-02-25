import UIKit

class MedicationItemCell: UICollectionViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var pillNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var onCircleTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial setup
        checkButton.layer.borderWidth = 2
        checkButton.layer.borderColor = UIColor.systemGray4.cgColor
        checkButton.layer.cornerRadius = checkButton.frame.width / 2
        checkButton.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the button stays circular
        checkButton.layer.cornerRadius = checkButton.frame.width / 2
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        onCircleTapped?()
    }

    func configureCell(with med: Medication) {
        pillNameLabel.text = med.name
        subtitleLabel.text = med.note
        timeLabel.text = med.time

        let checkColor = UIColor(named: "TabBarcolour") ?? .systemBlue
        
        if med.isTaken {
            // Taken state - show filled checkmark
            checkButton.backgroundColor = .white
            checkButton.layer.borderWidth = 0
            checkButton.layer.borderColor = UIColor.clear.cgColor
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.tintColor = checkColor
        } else {
            // Not taken state - show empty circle
            checkButton.backgroundColor = .clear
            checkButton.layer.borderWidth = 2
            checkButton.layer.borderColor = UIColor.systemGray4.cgColor
            checkButton.setImage(nil, for: .normal)
            checkButton.tintColor = .clear
        }
    }
}
