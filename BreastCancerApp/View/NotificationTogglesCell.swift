import UIKit

final class NotificationTogglesCell: UICollectionViewCell {

    // MARK: - Reuse Identifier
    static let reuseIdentifier = "NotificationTogglesCell"

    // MARK: - Outlets
    @IBOutlet private weak var cardView: UIView!

    @IBOutlet weak var exerciseSwitch: UISwitch!
    @IBOutlet weak var hydrationSwitch: UISwitch!
    @IBOutlet weak var appointmentsSwitch: UISwitch!
    @IBOutlet weak var medicationsSwitch: UISwitch!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
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

    // MARK: - UI Setup
    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
    }
}
