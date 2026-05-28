import UIKit

class MedicationStatsHeaderCell: UICollectionViewCell {
    @IBOutlet var totalScheduledLabel: UILabel!
    @IBOutlet var totalScheduledValueLabel: UILabel!
    @IBOutlet var takenLabel: UILabel!
    @IBOutlet var takenValueLabel: UILabel!
    @IBOutlet var missedLabel: UILabel!
    @IBOutlet var missedValueLabel: UILabel!
    @IBOutlet var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = .systemBackground

        totalScheduledLabel.font = .systemFont(ofSize: 15, weight: .regular)
        totalScheduledLabel.textColor = .systemGray
        totalScheduledLabel.text = "Total scheduled"

        takenLabel.font = .systemFont(ofSize: 15, weight: .regular)
        takenLabel.textColor = .systemGray
        takenLabel.text = "Taken"

        missedLabel.font = .systemFont(ofSize: 15, weight: .regular)
        missedLabel.textColor = .systemGray
        missedLabel.text = "Missed"

        totalScheduledValueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        totalScheduledValueLabel.textColor = .label

        takenValueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        takenValueLabel.textColor = .systemGreen

        missedValueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        missedValueLabel.textColor = .systemRed
    }

    func configure(total: Int, taken: Int, missed: Int) {
        totalScheduledValueLabel.text = "\(total)"
        takenValueLabel.text = "\(taken)"
        missedValueLabel.text = "\(missed)"
    }

    func configureEmpty() {
        totalScheduledValueLabel.text = "-"
        takenValueLabel.text = "-"
        missedValueLabel.text = "-"
    }
}
