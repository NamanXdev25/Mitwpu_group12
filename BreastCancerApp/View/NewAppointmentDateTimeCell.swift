import UIKit

class NewAppointmentDateTimeCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    var onDateChange: ((Date) -> Void)?
    var onNoneTapped: (() -> Void)?
    var onClearEndDate: (() -> Void)?

    private lazy var noneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("None", for: .normal)
        btn.tintColor = UIColor(named: "primary_color")
        btn.contentHorizontalAlignment = .right
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(noneTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .systemGray3
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return btn
    }()

    private var pickerTrailingConstraint: NSLayoutConstraint?
    private let clearButtonWidth: CGFloat = 28

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)

        guard let superview = datePicker.superview else { return }

        // Find the XIB trailing constraint (superview.trailing = datePicker.trailing + 16)
        // and deactivate it so we can control it dynamically.
        if let existing = superview.constraints.first(where: {
            ($0.firstItem as? UIView) == superview && $0.firstAttribute == .trailing &&
            ($0.secondItem as? UIDatePicker) == datePicker && $0.secondAttribute == .trailing
        }) {
            existing.isActive = false
        }

        // Re-create the trailing constraint so we can adjust its constant.
        let trailing = superview.trailingAnchor.constraint(
            equalTo: datePicker.trailingAnchor, constant: 16)
        trailing.isActive = true
        pickerTrailingConstraint = trailing

        superview.addSubview(noneButton)
        superview.addSubview(clearButton)

        NSLayoutConstraint.activate([
            noneButton.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor),
            noneButton.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),
            noneButton.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            noneButton.heightAnchor.constraint(equalTo: datePicker.heightAnchor),

            clearButton.leadingAnchor.constraint(equalTo: datePicker.trailingAnchor, constant: 6),
            clearButton.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: clearButtonWidth),
            clearButton.heightAnchor.constraint(equalToConstant: clearButtonWidth),
        ])
    }

    func configureAsDate(current: Date?) {
        titleLabel.text = "Date *"
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.date = current ?? Date()
        setPickerTrailing(compact: false)
        datePicker.isHidden = false
        noneButton.isHidden = true
        clearButton.isHidden = true
    }

    func configureAsTime(current: Date?) {
        titleLabel.text = "Time *"
        datePicker.datePickerMode = .time
        datePicker.minimumDate = nil
        datePicker.date = current ?? Date()
        setPickerTrailing(compact: false)
        datePicker.isHidden = false
        noneButton.isHidden = true
        clearButton.isHidden = true
    }

    func configureAsStartDate(current: Date?) {
        titleLabel.text = "Start Date"
        datePicker.datePickerMode = .date
        datePicker.minimumDate = nil
        datePicker.date = current ?? Date()
        setPickerTrailing(compact: false)
        datePicker.isHidden = false
        noneButton.isHidden = true
        clearButton.isHidden = true
    }

    func configureAsEndDate(date: Date?, enabled: Bool) {
        titleLabel.text = "End Date"
        datePicker.datePickerMode = .date
        datePicker.minimumDate = nil
        datePicker.isHidden = !enabled
        noneButton.isHidden = enabled
        clearButton.isHidden = !enabled
        setPickerTrailing(compact: enabled)
        if let d = date { datePicker.date = d }
    }

    private func setPickerTrailing(compact: Bool) {
        // When compact=true, shift picker left to leave room for the X button
        pickerTrailingConstraint?.constant = compact ? 16 + clearButtonWidth + 6 : 16
    }

    @objc private func noneTapped() {
        onNoneTapped?()
    }

    @objc private func clearTapped() {
        onClearEndDate?()
    }

    @objc private func pickerValueChanged() {
        onDateChange?(datePicker.date)
    }
}
