
import UIKit

class HealthDateCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var onDateChanged: ((Date) -> Void)?

    private var brandPink: UIColor {
        UIColor(named: "primary_pink") ?? UIColor(red: 215/255, green: 112/255, blue: 145/255, alpha: 1)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor             = .clear
        contentView.backgroundColor = .clear

        datePicker.datePickerMode           = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor                = brandPink
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        contentView.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(title: String, date: Date, isEditing: Bool = false) {
        backgroundColor             = .clear
        contentView.backgroundColor = .clear

        titleLabel.text      = title
        titleLabel.font      = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .label

        datePicker.date      = date
        datePicker.isEnabled = isEditing
        datePicker.tintColor = isEditing ? brandPink : .secondaryLabel

        datePicker.setNeedsLayout()
    }

    @objc private func dateChanged() {
        onDateChanged?(datePicker.date)
    }
}
