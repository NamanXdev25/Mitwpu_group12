import UIKit

final class NotificationTogglesCell: UICollectionViewCell {

    static let reuseIdentifier = "NotificationTogglesCell"

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var exerciseSwitch: UISwitch!
    @IBOutlet private weak var hydrationSwitch: UISwitch!
    @IBOutlet private weak var appointmentsSwitch: UISwitch!
    @IBOutlet private weak var medicationsSwitch: UISwitch!
    
    // Data source reference
    private let dataSource = UserProfileDataSource.shared

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
        
        // Add actions to switches
        exerciseSwitch.addTarget(self, action: #selector(exerciseSwitchChanged), for: .valueChanged)
        hydrationSwitch.addTarget(self, action: #selector(hydrationSwitchChanged), for: .valueChanged)
        appointmentsSwitch.addTarget(self, action: #selector(appointmentsSwitchChanged), for: .valueChanged)
        medicationsSwitch.addTarget(self, action: #selector(medicationsSwitchChanged), for: .valueChanged)
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
    
    // MARK: - Switch Actions
    
    @objc private func exerciseSwitchChanged(_ sender: UISwitch) {
        dataSource.updateNotificationSettings(exercise: sender.isOn)
        print("💪 Exercise notifications: \(sender.isOn)")
    }
    
    @objc private func hydrationSwitchChanged(_ sender: UISwitch) {
        dataSource.updateNotificationSettings(hydration: sender.isOn)
        print("💧 Hydration notifications: \(sender.isOn)")
    }
    
    @objc private func appointmentsSwitchChanged(_ sender: UISwitch) {
        dataSource.updateNotificationSettings(appointments: sender.isOn)
        print("📅 Appointments notifications: \(sender.isOn)")
    }
    
    @objc private func medicationsSwitchChanged(_ sender: UISwitch) {
        dataSource.updateNotificationSettings(medications: sender.isOn)
        print("💊 Medications notifications: \(sender.isOn)")
    }
}
