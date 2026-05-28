import UIKit

class EditSymptomCell: UITableViewCell {
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var symptomNameLabel: UILabel!
    @IBOutlet var infoButton: UIButton!

    var onActionTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        showsReorderControl = true
    }

    func configure(with symptom: Symptom, isInUserList: Bool) {
        symptomNameLabel.text = symptom.name

        if isInUserList {
            actionButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            actionButton.tintColor = .systemRed
        } else {
            actionButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            actionButton.tintColor = .systemGreen
        }
    }

    @IBAction func actionButtonTapped(_: UIButton) {
        onActionTapped?()
    }

    @IBAction func infoButtonTapped(_: UIButton) {
        onInfoTapped?()
    }
}
