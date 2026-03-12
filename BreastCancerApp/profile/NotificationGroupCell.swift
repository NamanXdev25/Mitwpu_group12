
import UIKit

class NotificationGroupCell: UICollectionViewCell {

    @IBOutlet weak var exerciseSwitch: UISwitch!
    @IBOutlet weak var hydrationSwitch: UISwitch!
    @IBOutlet weak var appointmentsSwitch: UISwitch!
    @IBOutlet weak var medicationSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
        
        exerciseSwitch.isOn = UserDefaults.standard.bool(forKey: "exerciseNotification")
        hydrationSwitch.isOn = UserDefaults.standard.bool(forKey: "hydrationNotification")
        appointmentsSwitch.isOn = UserDefaults.standard.bool(forKey: "appointmentsNotification")
        medicationSwitch.isOn = UserDefaults.standard.bool(forKey: "medicationNotification")
    }

    func configure(notifications: [NotificationItem]) {

        exerciseSwitch.isOn = notifications[0].isEnabled
        hydrationSwitch.isOn = notifications[1].isEnabled
        appointmentsSwitch.isOn = notifications[2].isEnabled
        medicationSwitch.isOn = notifications[3].isEnabled
    }

    @IBAction func exerciseChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "exerciseNotification")
    }

    @IBAction func hydrationChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "hydrationNotification")
    }

    @IBAction func appointmentsChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "appointmentsNotification")
    }

    @IBAction func medicationChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "medicationNotification")
    }
}
