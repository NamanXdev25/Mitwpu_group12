import UIKit

class TreatmentPhaseView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var phaseTitleLabel: UILabel!
    @IBOutlet weak var dropdownContainerView: UIView!
    @IBOutlet weak var dropdownLabel: UILabel!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var startDateContainerView: UIView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var cycleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Callback
    var onSaved: (() -> Void)?
    
    // MARK: - Properties
    private var phaseIndex: Int = 0
    private var phaseModel = TreatmentPhaseModel()
    private var selectedDate: Date? = nil

    private let pink      = UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let lightPink = UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        layer.cornerRadius = 14
        
        // Dropdown
        dropdownContainerView.backgroundColor = .white
        dropdownContainerView.layer.borderColor = UIColor.lightGray.cgColor
        dropdownContainerView.layer.borderWidth = 1
        dropdownContainerView.layer.cornerRadius = 10
        
        // Start date
        startDateContainerView.backgroundColor = .white
        startDateContainerView.layer.borderColor = UIColor.lightGray.cgColor
        startDateContainerView.layer.borderWidth = 1
        startDateContainerView.layer.cornerRadius = 10
        
        // Duration field
        durationTextField.layer.borderColor = UIColor.lightGray.cgColor
        durationTextField.layer.borderWidth = 1
        durationTextField.layer.cornerRadius = 10
        let durationPadding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        durationTextField.leftView = durationPadding
        durationTextField.leftViewMode = .always
        durationTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Cycle field
        cycleTextField.layer.borderColor = UIColor.lightGray.cgColor
        cycleTextField.layer.borderWidth = 1
        cycleTextField.layer.cornerRadius = 10
        let cyclePadding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        cycleTextField.leftView = cyclePadding
        cycleTextField.leftViewMode = .always
        cycleTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Save button
        saveButton.backgroundColor = lightPink
        saveButton.setTitleColor(UIColor(red: 0.75, green: 0.55, blue: 0.62, alpha: 1.0), for: .normal)
        saveButton.layer.cornerRadius = 14
        saveButton.isEnabled = false
        saveButton.adjustsImageWhenDisabled = false  // ← prevents iOS auto-dimming
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    // MARK: - IBActions
    @IBAction func dropdownTapped(_ sender: UIButton) {
        showTreatmentPicker()
    }
    
    @IBAction func dateTapped(_ sender: UIButton) {
        showDatePicker()
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard phaseModel.state == .editing else { return }
        phaseModel.state             = .saved
        phaseModel.treatmentType     = selectedTreatmentType()
        phaseModel.startDate         = selectedDate
        phaseModel.duration          = durationTextField.text ?? ""
        phaseModel.currentDayInCycle = cycleTextField.text ?? ""
        
        saveButton.setTitle("✓  Phase Details Saved", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.white, for: .highlighted)
        // ← NEVER call isEnabled = false — that's what causes dimming
        // Block interaction manually instead
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 1.0
        saveButton.titleLabel?.textColor = .white
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        dropdownButton.isUserInteractionEnabled    = false
        startDateButton.isUserInteractionEnabled   = false
        durationTextField.isUserInteractionEnabled = false
        cycleTextField.isUserInteractionEnabled    = false
        
        onSaved?()
    }
    
    @objc private func textFieldChanged() {
        updateSaveButtonState()
    }
    
    // MARK: - Configure
    func configure(index: Int) {
        phaseIndex = index
        phaseTitleLabel.text = "Phase \(index + 1)"
    }
    
    // MARK: - Helpers
    private func selectedTreatmentType() -> TreatmentType {
        let text = dropdownLabel.text ?? ""
        return TreatmentType.allCases.first { $0.rawValue == text } ?? .none
    }
    
    private func updateSaveButtonState() {
        guard phaseModel.state == .editing else { return }
        
        let treatmentSelected = phaseModel.treatmentType != .none
        let dateSelected      = selectedDate != nil
        let durationFilled    = !(durationTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let cycleFilled       = !(cycleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        
        let allFilled = treatmentSelected && dateSelected && durationFilled && cycleFilled
        
        saveButton.isEnabled       = allFilled
        saveButton.backgroundColor = allFilled ? pink : lightPink
        saveButton.setTitleColor(
            allFilled ? .white : UIColor(red: 0.75, green: 0.55, blue: 0.62, alpha: 1.0),
            for: .normal
        )
    }
}

// MARK: - Treatment Picker Popup
extension TreatmentPhaseView {
    
    private func showTreatmentPicker() {
        guard let window = self.window else { return }
        let options = TreatmentType.allCases.filter { $0 != .none }
        
        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.tag = 8001
        dimView.alpha = 0
        window.addSubview(dimView)
        
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0)
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        dimView.addSubview(container)
        
        let rowHeight: CGFloat = 52
        let popupHeight = CGFloat(options.count + 1) * rowHeight
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 300),
            container.heightAnchor.constraint(equalToConstant: popupHeight)
        ])
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        stack.addArrangedSubview(makePickerRow(title: "Select treatment", isSelected: true, isLast: false))
        
        for (i, option) in options.enumerated() {
            let row = makePickerRow(title: option.rawValue, isSelected: false, isLast: i == options.count - 1)
            row.tag = i
            row.isUserInteractionEnabled = true
            row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickerRowTapped(_:))))
            stack.addArrangedSubview(row)
        }
        
        UIView.animate(withDuration: 0.22) { dimView.alpha = 1 }
        
        let outsideTap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        outsideTap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(outsideTap)
    }
    
    private func makePickerRow(title: String, isSelected: Bool, isLast: Bool) -> UIView {
        let row = UIView()
        row.backgroundColor = isSelected
            ? UIColor(red: 0.75, green: 0.25, blue: 0.65, alpha: 1.0)
            : UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0)
        
        if isSelected {
            let check = UIImageView(image: UIImage(systemName: "checkmark"))
            check.tintColor = .white
            check.translatesAutoresizingMaskIntoConstraints = false
            check.contentMode = .scaleAspectFit
            row.addSubview(check)
            NSLayoutConstraint.activate([
                check.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 18),
                check.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                check.widthAnchor.constraint(equalToConstant: 18),
                check.heightAnchor.constraint(equalToConstant: 18)
            ])
        }
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: isSelected ? .semibold : .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: isSelected ? 48 : 18),
            label.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -18),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        
        if !isLast {
            let sep = UIView()
            sep.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            sep.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(sep)
            NSLayoutConstraint.activate([
                sep.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                sep.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                sep.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                sep.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        return row
    }
    
    @objc private func pickerRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        let options = TreatmentType.allCases.filter { $0 != .none }
        let index = row.tag
        guard index >= 0 && index < options.count else { return }
        
        let selected = options[index]
        dropdownLabel.text = selected.rawValue
        dropdownLabel.textColor = .black
        phaseModel.treatmentType = selected
        
        dismissPicker()
        updateSaveButtonState()
    }
    
    @objc private func dismissPicker() {
        guard let window = self.window,
              let dimView = window.viewWithTag(8001) else { return }
        UIView.animate(withDuration: 0.2, animations: { dimView.alpha = 0 }) { _ in
            dimView.removeFromSuperview()
        }
    }
}

// MARK: - Date Picker Popup
extension TreatmentPhaseView {
    
    private func showDatePicker() {
        guard let window = self.window else { return }
        
        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimView.tag = 8002
        dimView.alpha = 0
        window.addSubview(dimView)
        
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor   = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.15
        container.layer.shadowRadius  = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        dimView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 340),
            container.heightAnchor.constraint(equalToConstant: 420)
        ])
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = pink
        datePicker.date = selectedDate ?? Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(datePicker)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        doneButton.setTitleColor(pink, for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 4),
            doneButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            doneButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        doneButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.selectedDate = datePicker.date
            self.startDateLabel.text = self.formatDate(datePicker.date)
            self.startDateLabel.textColor = .black
            self.dismissDatePicker()
        }, for: .touchUpInside)
        
        let outsideTap = UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker))
        outsideTap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(outsideTap)
        
        UIView.animate(withDuration: 0.22) { dimView.alpha = 1 }
    }
    
    @objc private func datePickerChanged(_ picker: UIDatePicker) {
        selectedDate = picker.date
        startDateLabel.text = formatDate(picker.date)
        startDateLabel.textColor = .black
        updateSaveButtonState()
    }
    
    @objc private func dismissDatePicker() {
        guard let window = self.window,
              let dimView = window.viewWithTag(8002) else { return }
        UIView.animate(withDuration: 0.2, animations: { dimView.alpha = 0 }) { _ in
            dimView.removeFromSuperview()
        }
        updateSaveButtonState()
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }
}
