import UIKit

final class NotificationTogglesCell: UICollectionViewCell {

    // MARK: - Reuse
    static let reuseIdentifier = "NotificationTogglesCell"

    // MARK: - Outlets
    @IBOutlet private weak var cardView: UIView!

    @IBOutlet private weak var exerciseSwitch: UISwitch!
    @IBOutlet private weak var hydrationSwitch: UISwitch!
    @IBOutlet private weak var appointmentsSwitch: UISwitch!
    @IBOutlet private weak var medicationsSwitch: UISwitch!

    // MARK: - Constants
    private enum Layout {
        static let cornerRadius: CGFloat = 12
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetSwitches()
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
        cardView.layer.cornerRadius = Layout.cornerRadius
        cardView.clipsToBounds = true
    }

    // MARK: - Reuse
    private func resetSwitches() {
        exerciseSwitch.isOn = false
        hydrationSwitch.isOn = false
        appointmentsSwitch.isOn = false
        medicationsSwitch.isOn = false
    }
}
