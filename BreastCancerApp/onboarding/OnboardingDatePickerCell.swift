import UIKit

class OnboardingDatePickerCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!

    var onDateChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    func configure(title: String, fieldName _: String, maximumDate: Date? = Date()) {
        titleLabel.text = title
        datePicker.maximumDate = maximumDate
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
}
