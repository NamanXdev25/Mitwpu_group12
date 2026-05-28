import UIKit

class NewAppointmentSwitchCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var reminderSwitch: UISwitch!

    var onToggle: ((Bool) -> Void)?

    func configure(isOn: Bool) {
        reminderSwitch.isOn = isOn
    }

    @IBAction func switchToggled(_ sender: UISwitch) {
        onToggle?(sender.isOn)
    }
}
