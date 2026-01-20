import UIKit

final class NotificationTogglesCell: UICollectionViewCell {

    static let reuseIdentifier = "NotificationTogglesCell"

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var exerciseSwitch: UISwitch!
    @IBOutlet private weak var hydrationSwitch: UISwitch!
    @IBOutlet private weak var appointmentsSwitch: UISwitch!
    @IBOutlet private weak var medicationsSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        exerciseSwitch.isOn = false
        hydrationSwitch.isOn = false
        appointmentsSwitch.isOn = false
        medicationsSwitch.isOn = false
    }

    func configure(
        exerciseEnabled: Bool,
        hydrationEnabled: Bool,
        appointmentsEnabled: Bool,
        medicationsEnabled: Bool
    ) {
        exerciseSwitch.isOn = exerciseEnabled
        hydrationSwitch.isOn = hydrationEnabled
        appointmentsSwitch.isOn = appointmentsEnabled
        medicationsSwitch.isOn = medicationsEnabled
    }
}
