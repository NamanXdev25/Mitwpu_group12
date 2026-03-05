import UIKit

// MARK: - Phase Status
enum PhaseStatus {
    case notStarted
    case inProgress
    case completed
}

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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Callbacks
    var onSaved: (() -> Void)?
    var onStatusChanged: ((PhaseStatus) -> Void)?
    var onDeleteTapped: (() -> Void)?

    // MARK: - Properties
    private var phaseIndex: Int = 0
    private var phaseModel = TreatmentPhaseModel()
    private var selectedDate: Date? = nil
    private var isSaved = false
    private var statusTimer: Timer?

    private let pink      = UIColor(named: "pink") ?? UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let lightPink = UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)

    // Views that fade when saved
    private var fadableViews: [UIView] {
        [dropdownContainerView, startDateContainerView, durationTextField]
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    deinit { statusTimer?.invalidate() }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        layer.cornerRadius = 14

        dropdownContainerView.backgroundColor = .white
        dropdownContainerView.layer.borderColor = UIColor.lightGray.cgColor
        dropdownContainerView.layer.borderWidth = 1
        dropdownContainerView.layer.cornerRadius = 10

        startDateContainerView.backgroundColor = .white
        startDateContainerView.layer.borderColor = UIColor.lightGray.cgColor
        startDateContainerView.layer.borderWidth = 1
        startDateContainerView.layer.cornerRadius = 10

        durationTextField.layer.borderColor = UIColor.lightGray.cgColor
        durationTextField.layer.borderWidth = 1
        durationTextField.layer.cornerRadius = 10
        durationTextField.keyboardType = .numberPad
        durationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        durationTextField.leftViewMode = .always
        durationTextField.delegate = self
        durationTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

        // Save button: rebuild config from scratch.
        // XIB sets enabled=NO which greys out filled buttons; we fix that here.
        // Also XIB has no baseBackgroundColor set, so pink would never appear without this.
        // Gate interaction via isUserInteractionEnabled + alpha only, never isEnabled.
        saveButton.isEnabled = true
        var saveCfg = UIButton.Configuration.filled()
        saveCfg.baseBackgroundColor = pink
        saveCfg.baseForegroundColor = .white
        saveCfg.attributedTitle = AttributedString(
            "Save Phase Details",
            attributes: AttributeContainer([
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ])
        )
        saveButton.configuration = saveCfg
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.4
        saveButton.isHidden = false

        // Edit button: XIB owns title/emoji/font/color, only bg + corners here
        applyEditButtonStyle()
        editButton.isHidden = true
        editButton.alpha = 1.0
        editButton.addTarget(self, action: #selector(editButtonTappedAction), for: .touchUpInside)

        // Delete button — wired from XIB outlet
        deleteButton.addTarget(self, action: #selector(deleteButtonTappedAction), for: .touchUpInside)
    }

    // MARK: - Edit Button Style (no Configuration — preserves XIB title/emoji/font)
    private func applyEditButtonStyle() {
        editButton.backgroundColor = lightPink
        editButton.setTitleColor(pink, for: .normal)
    }

    // MARK: - IBActions
    @IBAction func dropdownTapped(_ sender: UIButton) { showTreatmentPicker() }
    @IBAction func dateTapped(_ sender: UIButton)     { showDatePicker() }
    @IBAction func saveTapped(_ sender: UIButton)     { commitSave() }
    @IBAction func editTapped(_ sender: UIButton)     { revertToEditMode() }
    @IBAction func deleteTapped(_ sender: UIButton)   { onDeleteTapped?() }

    @objc private func editButtonTappedAction()   { revertToEditMode() }
    @objc private func deleteButtonTappedAction() { onDeleteTapped?() }

    @objc private func textFieldChanged() {
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    // MARK: - Save → Enter saved state
    private func commitSave() {
        guard allFieldsFilled() else { return }
        isSaved = true

        phaseModel.state         = .saved
        phaseModel.treatmentType = selectedTreatmentType()
        phaseModel.startDate     = selectedDate
        phaseModel.duration      = durationTextField.text ?? ""

        // Lock interaction
        dropdownButton.isUserInteractionEnabled    = false
        startDateButton.isUserInteractionEnabled   = false
        durationTextField.isUserInteractionEnabled = false

        // Swap buttons — outside animate block
        saveButton.isHidden = true
        editButton.isHidden = false
        editButton.alpha = 1.0

        // Fade form views
        UIView.animate(withDuration: 0.3) {
            self.fadableViews.forEach { $0.alpha = 0.35 }
        }

        startStatusTimer()
        evaluateAndBroadcastStatus()
        onSaved?()
    }

    // MARK: - Edit → Revert to initial state
    private func revertToEditMode() {
        isSaved = false
        phaseModel.state = .editing

        // Unlock interaction
        dropdownButton.isUserInteractionEnabled    = true
        startDateButton.isUserInteractionEnabled   = true
        durationTextField.isUserInteractionEnabled = true

        // Swap buttons -- outside animate block
        editButton.isHidden = true
        saveButton.isEnabled = true   // re-assert; UIKit may reset when isHidden toggles
        saveButton.isHidden = false

        UIView.animate(withDuration: 0.3) {
            self.fadableViews.forEach { $0.alpha = 1.0 }
        }

        statusTimer?.invalidate()
        updateSaveButtonState()
        onStatusChanged?(.notStarted)
    }

    // MARK: - Save Button State
    private func updateSaveButtonState() {
        let allFilled = allFieldsFilled()
        // Always keep isEnabled=true; use isUserInteractionEnabled + alpha to fake disabled.
        // isEnabled=false on a filled-config button causes UIKit to apply a grey tint.
        saveButton.isEnabled = true
        saveButton.isUserInteractionEnabled = allFilled
        UIView.animate(withDuration: 0.2) {
            self.saveButton.alpha = allFilled ? 1.0 : 0.4
        }
    }

    // MARK: - Status Engine
    func currentStatus() -> PhaseStatus {
        guard isSaved,
              let startDate = selectedDate,
              let durationDays = Int(phaseModel.duration),
              durationDays > 0 else { return .notStarted }

        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = cal.startOfDay(for: startDate)
        guard let endDate = cal.date(byAdding: .day, value: durationDays, to: start) else { return .notStarted }

        if today < start        { return .notStarted }
        else if today < endDate { return .inProgress }
        else                    { return .completed  }
    }

    private func startStatusTimer() {
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.evaluateAndBroadcastStatus()
        }
    }

    private func evaluateAndBroadcastStatus() {
        onStatusChanged?(currentStatus())
    }

    // MARK: - Configure
    func configure(index: Int) {
        phaseIndex = index
        phaseTitleLabel.text = "Phase \(index + 1)"
    }

    // MARK: - Helpers
    private func allFieldsFilled() -> Bool {
        let treatmentSelected = phaseModel.treatmentType != .none
        let dateSelected      = selectedDate != nil
        let durationFilled    = !(durationTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        return treatmentSelected && dateSelected && durationFilled
    }

    private func selectedTreatmentType() -> TreatmentType {
        let text = dropdownLabel.text ?? ""
        return TreatmentType.allCases.first { $0.rawValue == text } ?? .none
    }
}

// MARK: - UITextFieldDelegate (numbers only)
extension TreatmentPhaseView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        return string.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
    }
}

// MARK: - Treatment Picker Popup
extension TreatmentPhaseView {

    private func showTreatmentPicker() {
        guard let window = self.window else { return }
        let options = TreatmentType.allCases.filter { $0 != .none }

        // Blur backdrop — native iOS feel
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let dimView = UIVisualEffectView(effect: blurEffect)
        dimView.frame = window.bounds
        dimView.tag = 8001
        dimView.alpha = 0
        window.addSubview(dimView)

        // Glass container using UIVisualEffectView + vibrancy
        let sheetBlur = UIBlurEffect(style: .systemMaterial)
        let container = UIVisualEffectView(effect: sheetBlur)
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        container.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        container.alpha = 0
        dimView.contentView.addSubview(container)

        let rowHeight: CGFloat = 52
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 300),
            container.heightAnchor.constraint(equalToConstant: CGFloat(options.count + 1) * rowHeight)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let nothingSelected = phaseModel.treatmentType == .none
        stack.addArrangedSubview(makePickerRow(title: "Select treatment...", isSelected: nothingSelected, isLast: false))
        for (i, option) in options.enumerated() {
            let isCurrentlySelected = phaseModel.treatmentType == option
            let row = makePickerRow(title: option.rawValue, isSelected: isCurrentlySelected, isLast: i == options.count - 1)
            row.tag = i
            row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickerRowTapped(_:))))
            stack.addArrangedSubview(row)
        }

        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.78,
                       initialSpringVelocity: 0.4,
                       options: .curveEaseOut) {
            dimView.alpha = 1
            container.alpha = 1
            container.transform = .identity
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        tap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(tap)
    }

    private func makePickerRow(title: String, isSelected: Bool, isLast: Bool) -> UIView {
        let row = UIView()
        // Glass rows: clear bg, selected gets a subtle pink tint
        row.backgroundColor = isSelected
            ? pink.withAlphaComponent(0.85)
            : UIColor.clear

        if isSelected {
            let check = UIImageView(image: UIImage(systemName: "checkmark"))
            check.tintColor = .white
            check.translatesAutoresizingMaskIntoConstraints = false
            check.contentMode = .scaleAspectFit
            row.addSubview(check)
            NSLayoutConstraint.activate([
                check.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 18),
                check.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                check.widthAnchor.constraint(equalToConstant: 16),
                check.heightAnchor.constraint(equalToConstant: 16)
            ])
        }

        let label = UILabel()
        label.text = title
        label.textColor = isSelected ? .white : .label
        label.font = UIFont.systemFont(ofSize: 16, weight: isSelected ? .semibold : .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: isSelected ? 46 : 18),
            label.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -18),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        if !isLast {
            let sep = UIView()
            sep.backgroundColor = UIColor.separator.withAlphaComponent(0.4)
            sep.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(sep)
            NSLayoutConstraint.activate([
                sep.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 18),
                sep.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -18),
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
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    @objc private func dismissPicker() {
        guard let window = self.window, let dimView = window.viewWithTag(8001) else { return }
        UIView.animate(withDuration: 0.25, animations: {
            dimView.alpha = 0
        }) { _ in dimView.removeFromSuperview() }
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
        datePicker.maximumDate = Date()
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
            if self.isSaved { self.revertToEditMode() }
            self.dismissDatePicker()
            self.updateSaveButtonState()
        }, for: .touchUpInside)

        let outsideTap = UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker))
        outsideTap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(outsideTap)

        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) { dimView.alpha = 1 }
    }

    @objc private func datePickerChanged(_ picker: UIDatePicker) {
        selectedDate = picker.date
        startDateLabel.text = formatDate(picker.date)
        startDateLabel.textColor = .black
    }

    @objc private func dismissDatePicker() {
        guard let window = self.window, let dimView = window.viewWithTag(8002) else { return }
        UIView.animate(withDuration: 0.2, animations: { dimView.alpha = 0 }) { _ in dimView.removeFromSuperview() }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }
}
