import UIKit

class MedicationCell: UITableViewCell {

    @IBOutlet weak var pillNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        backgroundColor = .clear
    }

    func configure(with medication: Medication) {
        pillNameLabel.text = medication.name
        timeLabel.text = medication.time
    }
}
