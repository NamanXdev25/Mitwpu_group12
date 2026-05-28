import UIKit

class NewAppointmentReminderTimeCell: UICollectionViewCell {
    @IBOutlet var addReminderButton: UIButton!

    var onAdd: (() -> Void)?

    var isMedicationContext: Bool = false {
        didSet { updateTitle() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateTitle()
    }

    private func updateTitle() {
        guard addReminderButton != nil else { return }
        var config = addReminderButton.configuration ?? UIButton.Configuration.plain()
        config.title = isMedicationContext ? "Add Time" : "Add Reminder"
        addReminderButton.configuration = config
    }

    @IBAction func addReminderTapped(_: UIButton) {
        onAdd?()
    }
}
