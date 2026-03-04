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
    @IBOutlet weak var editButton: UIButton!   // ← must be added + connected in XIB

    // MARK: - Colors
    private let pink            = UIColor(named: "pink") ?? UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let lightPink       = UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)
    private let savedGreenColor = UIColor(red: 0.2,  green: 0.6,  blue: 0.2,  alpha: 1.0)
    private let savedGreenBg    = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)

    // MARK: - UserDefaults Keys
    private let kDate     = "postTreatment_date"
    private let kSymptoms = "postTreatment_symptoms"
    private let kSaved    = "postTreatment_isSaved"

    // MARK: - State
    private var selectedSymptoms: Set<String> = []
    private var selectedDate: Date?
    private var isSaved = false
    private var symptomTitles: [UIButton: String] = [:]

    var onDateTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?

    // Views that fade when saved (everything except title, statusLabel, editButton)
    private var fadableViews: [UIView] {
        [dateContainerView, painButton, numbnessButton,
         swellingButton, stiffnessButton, fatigueButton]
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    // MARK: - Setup
    private func setupCell() {
        UserDefaults.standard.removeObject(forKey: kDate)
        UserDefaults.standard.removeObject(forKey: kSymptoms)
        UserDefaults.standard.removeObject(forKey: kSaved)

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

        // Save button — styled in code
        saveButton.layer.cornerRadius = 14
        saveButton.clipsToBounds = true
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.backgroundColor = pink
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.isHidden = false
        saveButton.alpha = 0.4
        saveButton.isUserInteractionEnabled = false

        // Edit button — only bg + corners, XIB owns title/emoji/font/color
        applyEditButtonStyle()
        editButton.isHidden = true
        editButton.alpha = 1.0
        editButton.addTarget(self, action: #selector(editButtonTappedAction), for: .touchUpInside)

        loadPersistedState()
    }

    // MARK: - Edit Button Style (no Configuration — preserves XIB title/emoji/font)
    private func applyEditButtonStyle() {
        editButton.backgroundColor = lightPink
        editButton.layer.cornerRadius = 14
        editButton.clipsToBounds = true
        editButton.setTitleColor(pink, for: .normal)
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
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    // MARK: - IBActions
    @IBAction func dateTapped(_ sender: UIButton)       { showInternalDatePicker() }
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

    // MARK: - Save → Enter saved state
    private func commitSave() {
        isSaved = true
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = savedGreenBg
        statusLabel.textColor = savedGreenColor
        persistState()
        enterSavedState(animated: true)
    }

    private func enterSavedState(animated: Bool) {
        applyEditButtonStyle()

        // Lock all interaction
        symptomTitles.keys.forEach { $0.isUserInteractionEnabled = false }
        dateButton.isUserInteractionEnabled = false

        // Swap buttons OUTSIDE animate block — isHidden doesn't animate
        saveButton.isHidden = true
        editButton.isHidden = false
        editButton.alpha = 1.0

        // Only fade the form views
        let block = { self.fadableViews.forEach { $0.alpha = 0.35 } }
        animated ? UIView.animate(withDuration: 0.3, animations: block) : block()
    }

    // MARK: - Edit → Revert to initial unsaved state
    private func revertToEditMode() {
        isSaved = false

        // Unlock all interaction
        symptomTitles.keys.forEach { $0.isUserInteractionEnabled = true }
        dateButton.isUserInteractionEnabled = true

        // Swap buttons OUTSIDE animate block — isHidden doesn't animate
        editButton.isHidden = true
        saveButton.isHidden = false

        // Restore form views to full opacity
        UIView.animate(withDuration: 0.3) {
            self.fadableViews.forEach { $0.alpha = 1.0 }
        }

        // Re-check save button enabled/alpha based on current selections
        updateSaveButtonState()
        UserDefaults.standard.set(false, forKey: kSaved)
    }

    // MARK: - Save Button State
    private func updateSaveButtonState() {
        let enabled = selectedDate != nil && !selectedSymptoms.isEmpty
        saveButton.isUserInteractionEnabled = enabled
        UIView.animate(withDuration: 0.25) {
            self.saveButton.alpha = enabled ? 1.0 : 0.4
        }
    }

    // MARK: - Persistence
    private func persistState() {
        let d = UserDefaults.standard
        d.set(selectedDate, forKey: kDate)
        d.set(Array(selectedSymptoms), forKey: kSymptoms)
        d.set(true, forKey: kSaved)
    }

    private func loadPersistedState() {
        let d = UserDefaults.standard
        if let date = d.object(forKey: kDate) as? Date {
            selectedDate = date
            let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"
            dateLabel.text = f.string(from: date)
            dateLabel.textColor = .black
        }
        if let symptoms = d.array(forKey: kSymptoms) as? [String] {
            selectedSymptoms = Set(symptoms)
        }
        for (btn, title) in symptomTitles {
            selectedSymptoms.contains(title) ? applySelectedStyle(to: btn) : applyDeselectedStyle(to: btn)
        }
        if d.bool(forKey: kSaved) {
            isSaved = true
            statusLabel.text = "Completed"
            statusLabel.backgroundColor = savedGreenBg
            statusLabel.textColor = savedGreenColor
            enterSavedState(animated: false)
        } else {
            updateSaveButtonState()
        }
    }

    // MARK: - Date Picker
    private func showInternalDatePicker() {
        guard let window = self.window else { return }

        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimView.tag = 9001
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

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = pink
        picker.maximumDate = Date()
        picker.date = selectedDate ?? Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(picker)

        let doneBtn = UIButton(type: .system)
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        doneBtn.setTitleColor(pink, for: .normal)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(doneBtn)

        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            doneBtn.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 4),
            doneBtn.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            doneBtn.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        picker.addTarget(self, action: #selector(pickerChanged(_:)), for: .valueChanged)
        doneBtn.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.commitDate(picker.date)
            self.dismissPicker()
        }, for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        tap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(tap)

        UIView.animate(withDuration: 0.22) { dimView.alpha = 1 }
    }

    @objc private func pickerChanged(_ picker: UIDatePicker) { commitDate(picker.date) }

    private func commitDate(_ date: Date) {
        selectedDate = date
        let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"
        dateLabel.text = f.string(from: date)
        dateLabel.textColor = .black
        if isSaved { revertToEditMode() }
        updateSaveButtonState()
    }

    @objc private func dismissPicker() {
        guard let window = self.window, let dim = window.viewWithTag(9001) else { return }
        UIView.animate(withDuration: 0.2, animations: { dim.alpha = 0 }) { _ in dim.removeFromSuperview() }
    }

    // MARK: - Public
    func updateSelectedDate(_ date: Date) { commitDate(date) }

    func configure() {
        for (btn, title) in symptomTitles {
            selectedSymptoms.contains(title) ? applySelectedStyle(to: btn) : applyDeselectedStyle(to: btn)
        }
        if !isSaved { updateSaveButtonState() }
    }

    func getCellHeight() -> CGFloat { return 370 }
}
