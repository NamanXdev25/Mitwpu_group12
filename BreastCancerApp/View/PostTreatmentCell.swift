import UIKit

class PostTreatmentCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var painButton: UIButton!
    @IBOutlet weak var numbnessButton: UIButton!
    @IBOutlet weak var swellingButton: UIButton!
    @IBOutlet weak var stiffnessButton: UIButton!
    @IBOutlet weak var fatigueButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    // MARK: - Colors
    private let pink            = UIColor(named: "pink") ?? UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let lightPink       = UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)
    private let savedGreenColor = UIColor(red: 0.2,  green: 0.6,  blue: 0.2,  alpha: 1.0)
    private let savedGreenBg    = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)

    // MARK: - State (VC owns all persistence via restoreState)
    private var selectedSymptoms: Set<String> = []
    private var selectedDate: Date?
    private var isSaved = false
    private var symptomTitles: [UIButton: String] = [:]
    private var lockOverlayView: UIView?

    // Date picker overlay references (mirrors DiagnosisCell pattern)
    private var overlayView: UIView?
    private var datePickerContainerView: UIView?

    // MARK: - Callbacks
    var onDateTapped: (() -> Void)?
    var onSaveButtonTapped: (() -> Void)?
    var onEditButtonTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?
    var onDateChanged: ((Date?) -> Void)?
    var onSymptomsChanged: ((Set<String>) -> Void)?

    private var fadableViews: [UIView] {
        [dateContainerView, painButton, numbnessButton,
         swellingButton, stiffnessButton, fatigueButton]
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    // MARK: - Lock Overlay
    func setLocked(_ locked: Bool) {
        locked ? showLockOverlay() : removeLockOverlay()
    }

    private func showLockOverlay() {
        guard lockOverlayView == nil else { return }
        let overlay = UIView()
        overlay.backgroundColor = UIColor.white.withAlphaComponent(0.65)
        overlay.layer.cornerRadius = 16
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isUserInteractionEnabled = true

        let lockImage = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockImage.tintColor = UIColor(white: 0.5, alpha: 1)
        lockImage.contentMode = .scaleAspectFit
        lockImage.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(lockImage)
        NSLayoutConstraint.activate([
            lockImage.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            lockImage.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            lockImage.widthAnchor.constraint(equalToConstant: 28),
            lockImage.heightAnchor.constraint(equalToConstant: 28)
        ])

        contentView.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        lockOverlayView = overlay
    }

    private func removeLockOverlay() {
        lockOverlayView?.removeFromSuperview()
        lockOverlayView = nil
    }

    // MARK: - Setup
    private func setupCell() {

        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .white

        statusLabel.text = "Not Started"
        statusLabel.textColor = UIColor(white: 0.5, alpha: 1)
        statusLabel.backgroundColor = UIColor(white: 0.94, alpha: 1)
        statusLabel.layer.cornerRadius = 10
        statusLabel.layer.masksToBounds = true

        dateContainerView.layer.borderColor = UIColor.lightGray.cgColor
        dateContainerView.layer.borderWidth = 1
        dateContainerView.layer.cornerRadius = 10

        symptomTitles = [
            painButton:      "Pain",
            numbnessButton:  "Numbness",
            swellingButton:  "Swelling",
            stiffnessButton: "Stiffness",
            fatigueButton:   "Fatigue"
        ]

        for (btn, _) in symptomTitles {
            btn.layer.cornerRadius = 20
            btn.clipsToBounds = true
            btn.addTarget(self, action: #selector(symptomTapped(_:)), for: .touchUpInside)
            applyDeselectedStyle(to: btn)
        }

        saveButton.layer.cornerRadius = 14
        saveButton.clipsToBounds = true
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.backgroundColor = pink
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.isHidden = false
        saveButton.alpha = 0.4
        saveButton.isUserInteractionEnabled = false

        applyEditButtonStyle()
        editButton.isHidden = true
        editButton.alpha = 1.0
        editButton.addTarget(self, action: #selector(editButtonTappedAction), for: .touchUpInside)
    }

    private func applyEditButtonStyle() {
        editButton.backgroundColor = lightPink
        editButton.layer.cornerRadius = 14
        editButton.clipsToBounds = true
        editButton.setTitleColor(pink, for: .normal)
    }

    // MARK: - Restore State (called by JourneyViewController on every dequeue)
    func restoreState(_ state: SavedPostTreatmentState) {
        selectedDate     = state.selectedDate
        selectedSymptoms = state.selectedSymptoms
        isSaved          = state.isSaved

        if let date = selectedDate {
            let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"
            dateLabel.text      = f.string(from: date)
            dateLabel.textColor = .black
        } else {
            dateLabel.text      = nil
            dateLabel.textColor = .placeholderText
        }

        for (btn, title) in symptomTitles {
            selectedSymptoms.contains(title) ? applySelectedStyle(to: btn) : applyDeselectedStyle(to: btn)
        }

        if isSaved {
            statusLabel.text            = "Completed"
            statusLabel.backgroundColor = savedGreenBg
            statusLabel.textColor       = savedGreenColor
            enterSavedState(animated: false)
        } else {
            statusLabel.text            = "Not Started"
            statusLabel.textColor       = UIColor(white: 0.5, alpha: 1)
            statusLabel.backgroundColor = UIColor(white: 0.94, alpha: 1)
            symptomTitles.keys.forEach { $0.isUserInteractionEnabled = true }
            dateButton.isUserInteractionEnabled = true
            saveButton.isHidden  = false
            editButton.isHidden  = true
            fadableViews.forEach { $0.alpha = 1.0 }
            updateSaveButtonState()
        }
    }

    // MARK: - Symptom Styling
    private func applySelectedStyle(to button: UIButton) {
        var cfg = button.configuration ?? UIButton.Configuration.filled()
        cfg.baseBackgroundColor = pink
        cfg.baseForegroundColor = .white
        button.configuration = cfg
    }

    private func applyDeselectedStyle(to button: UIButton) {
        var cfg = button.configuration ?? UIButton.Configuration.filled()
        cfg.baseBackgroundColor = lightPink
        cfg.baseForegroundColor = pink
        button.configuration = cfg
    }

    // MARK: - Symptom Tap
    @objc private func symptomTapped(_ sender: UIButton) {
        guard let title = symptomTitles[sender] else { return }
        if selectedSymptoms.contains(title) {
            selectedSymptoms.remove(title)
            applyDeselectedStyle(to: sender)
        } else {
            selectedSymptoms.insert(title)
            applySelectedStyle(to: sender)
        }
        onSymptomsChanged?(selectedSymptoms)
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    // MARK: - IBActions
    @IBAction func dateTapped(_ sender: UIButton)       { showDatePickerOverlay() }
    @IBAction func painTapped(_ sender: UIButton)       {}
    @IBAction func numbnessTapped(_ sender: UIButton)   {}
    @IBAction func swellingTapped(_ sender: UIButton)   {}
    @IBAction func stiffnessTapped(_ sender: UIButton)  {}
    @IBAction func fatigueTapped(_ sender: UIButton)    {}

    @IBAction func saveTapped(_ sender: UIButton) {
        guard selectedDate != nil, !selectedSymptoms.isEmpty else { return }
        commitSave()
    }

    @IBAction func editTapped(_ sender: UIButton) {
        revertToEditMode()
    }

    @objc private func editButtonTappedAction() {
        revertToEditMode()
    }

    // MARK: - Save
    private func commitSave() {
        isSaved = true
        statusLabel.text            = "Completed"
        statusLabel.backgroundColor = savedGreenBg
        statusLabel.textColor       = savedGreenColor
        enterSavedState(animated: true)
        onSaveButtonTapped?()
    }

    private func enterSavedState(animated: Bool) {
        applyEditButtonStyle()
        symptomTitles.keys.forEach { $0.isUserInteractionEnabled = false }
        dateButton.isUserInteractionEnabled = false
        saveButton.isHidden = true
        editButton.isHidden = false
        editButton.alpha    = 1.0
        let block = { self.fadableViews.forEach { $0.alpha = 0.35 } }
        animated ? UIView.animate(withDuration: 0.3, animations: block) : block()
    }

    // MARK: - Edit
    private func revertToEditMode() {
        isSaved = false
        symptomTitles.keys.forEach { $0.isUserInteractionEnabled = true }
        dateButton.isUserInteractionEnabled = true
        editButton.isHidden = true
        saveButton.isHidden = false
        statusLabel.text            = "Not Started"
        statusLabel.textColor       = UIColor(white: 0.5, alpha: 1)
        statusLabel.backgroundColor = UIColor(white: 0.94, alpha: 1)
        UIView.animate(withDuration: 0.3) {
            self.fadableViews.forEach { $0.alpha = 1.0 }
        }
        updateSaveButtonState()
        onEditButtonTapped?()
    }

    // MARK: - Save Button State
    private func updateSaveButtonState() {
        let enabled = selectedDate != nil && !selectedSymptoms.isEmpty
        saveButton.isUserInteractionEnabled = enabled
        UIView.animate(withDuration: 0.25) {
            self.saveButton.alpha = enabled ? 1.0 : 0.4
        }
    }

    // MARK: - Date Picker Overlay (mirrors DiagnosisCell exactly — no fixed height on container)
    private func showDatePickerOverlay() {
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }

        // --- Dim overlay ---
        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerOverlay))
        tapGesture.cancelsTouchesInView = false
        dimView.addGestureRecognizer(tapGesture)
        overlayView = dimView

        // --- White card container (NO fixed heightAnchor — lets picker resize freely) ---
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainerView = container

        // --- Inline date picker ---
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline   // tapping year header → scroll wheel works because container has no fixed height
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        picker.tintColor = pink
        picker.date = selectedDate ?? Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

        // --- Reset / Done buttons ---
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(pink, for: .normal)
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        resetButton.addTarget(self, action: #selector(resetDateTapped), for: .touchUpInside)

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(pink, for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        doneButton.addTarget(self, action: #selector(dismissDatePickerOverlay), for: .touchUpInside)

        buttonStack.addArrangedSubview(resetButton)
        buttonStack.addArrangedSubview(doneButton)

        container.addSubview(picker)
        container.addSubview(buttonStack)

        window.addSubview(dimView)
        window.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 350),

            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),

            buttonStack.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10),
            buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Spring-in animation
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        container.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut) {
            dimView.alpha = 1
            container.alpha = 1
            container.transform = .identity
        }
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        // Live-update label as user scrolls — no need to tap Done to see selection
        selectedDate = sender.date
        let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"
        dateLabel.text      = f.string(from: sender.date)
        dateLabel.textColor = .black
        onDateChanged?(sender.date)
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    @objc private func resetDateTapped() {
        clearSelectedDate()
        dismissDatePickerOverlay()
    }

    @objc private func dismissDatePickerOverlay() {
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView?.alpha = 0
            self.datePickerContainerView?.alpha = 0
            self.datePickerContainerView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.overlayView?.removeFromSuperview()
            self.datePickerContainerView?.removeFromSuperview()
            self.overlayView = nil
            self.datePickerContainerView = nil
        }
    }

    // MARK: - Public helpers (called by JourneyViewController calendar popup)
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"
        dateLabel.text      = f.string(from: date)
        dateLabel.textColor = .black
        onDateChanged?(date)
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    func clearSelectedDate() {
        selectedDate        = nil
        dateLabel.text      = nil
        dateLabel.textColor = .placeholderText
        onDateChanged?(nil)
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    func configure() {
        for (btn, title) in symptomTitles {
            selectedSymptoms.contains(title) ? applySelectedStyle(to: btn) : applyDeselectedStyle(to: btn)
        }
        if !isSaved { updateSaveButtonState() }
    }

    func getCellHeight() -> CGFloat { return 397 }
}
