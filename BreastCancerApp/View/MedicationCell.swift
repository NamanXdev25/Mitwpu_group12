import UIKit

class MedicationCell: UITableViewCell {
    @IBOutlet var pillNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }

    func configure(with medication: Medication) {
        pillNameLabel.text = medication.name
        timeLabel.text = medication.time
    }
}
