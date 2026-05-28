import UIKit

class MedicationItemCell: UICollectionViewCell {
    @IBOutlet var checkButton: UIButton!
    @IBOutlet var pillNameLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    var onCircleTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.layer.borderWidth = 2
        checkButton.layer.borderColor = UIColor.systemGray4.cgColor
        checkButton.layer.cornerRadius = checkButton.frame.width / 2
        checkButton.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        checkButton.layer.cornerRadius = checkButton.frame.width / 2
    }

    @IBAction func checkButtonTapped(_: UIButton) {
        onCircleTapped?()
    }

    func configureCell(with med: Medication) {
        pillNameLabel.text = med.name
        subtitleLabel.text = med.note
        timeLabel.text = med.time

        let checkColor = UIColor(named: "TabBarcolour") ?? .systemBlue

        if med.isTaken {
            checkButton.backgroundColor = .white
            checkButton.layer.borderWidth = 0
            checkButton.layer.borderColor = UIColor.clear.cgColor
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.tintColor = checkColor
        } else {
            checkButton.backgroundColor = .clear
            checkButton.layer.borderWidth = 2
            checkButton.layer.borderColor = UIColor.systemGray4.cgColor
            checkButton.setImage(nil, for: .normal)
            checkButton.tintColor = .clear
        }
    }
}
