
import UIKit

class NewAppointmentDateTimeCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    var onDateChange: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
    }

    func configureAsDate(current: Date?) {
        titleLabel.text = "Date *"
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.date = current ?? Date()
    }

    func configureAsTime(current: Date?) {
        titleLabel.text = "Time *"
        datePicker.datePickerMode = .time
        datePicker.minimumDate = nil
        datePicker.date = current ?? Date()
    }

    @objc private func pickerValueChanged() {
        onDateChange?(datePicker.date)
    }
}
