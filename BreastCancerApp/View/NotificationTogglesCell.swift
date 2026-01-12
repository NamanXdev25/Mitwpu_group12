import UIKit

final class NotificationTogglesCell: UICollectionViewCell {

    // MARK: - Reuse Identifier
    static let reuseIdentifier = "NotificationTogglesCell"

    // MARK: - Outlets (connect from XIB)
    @IBOutlet weak var exerciseSwitch: UISwitch!
    @IBOutlet weak var hydrationSwitch: UISwitch!
    @IBOutlet weak var appointmentsSwitch: UISwitch!
    @IBOutlet weak var medicationsSwitch: UISwitch!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyleDisabled()
    }

    // MARK: - Configuration
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

    // MARK: - Helpers
    private func selectionStyleDisabled() {
        // Prevent highlight on tap (collection view default behavior)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
