import UIKit

class WaitCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var daysWaitedLabel: UILabel!
    @IBOutlet weak var daysTextField: UITextField!
    @IBOutlet weak var stepperUpButton: UIButton!
    @IBOutlet weak var stepperDownButton: UIButton!
    @IBOutlet weak var feelingsQuestionLabel: UILabel!
    @IBOutlet weak var feelingsSubtitleLabel: UILabel!

    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var anxiousButton: UIButton!
    @IBOutlet weak var overwhelmedButton: UIButton!
    @IBOutlet weak var scaredButton: UIButton!
    @IBOutlet weak var angryButton: UIButton!
    @IBOutlet weak var numbButton: UIButton!
    @IBOutlet weak var hopefulButton: UIButton!
    @IBOutlet weak var calmButton: UIButton!

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!   // connect in XIB

    // MARK: - Colors
    private let lightPinkColor  = UIColor(displayP3Red: 0.9882352941, green: 0.9098039216, blue: 0.9372549020, alpha: 1.0)
    private let darkPinkColor   = UIColor(displayP3Red: 0.9098039216, green: 0.4156862745, blue: 0.5725490196, alpha: 1.0)
    private let inProgressBg    = UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)
    private let inProgressText  = UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let savedGreenColor = UIColor(red: 0.2,  green: 0.6,  blue: 0.2,  alpha: 1.0)
    private let savedGreenBg    = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
    private let notStartedBg    = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

    // MARK: - Persistence Keys
    private let kSaveDate  = "waitCell_saveDate"
    private let kDaysInput = "waitCell_daysInput"
    private let kFeelings  = "waitCell_feelings"

    // MARK: - State
    private var selectedFeelings: Set<String> = []
    private var currentDays: Int = 0
    private var feelingButtons: [UIButton] = []
    private var buttonFeelingMap: [UIButton: String] = [:]
    private var isSaved: Bool = false
    private var didSetupButtons = false

    var onSaveButtonTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?

    // MARK: - Views that fade on save (everything except title, status badge, edit button)
    private var fadableViews: [UIView] {
        return [
            daysWaitedLabel, daysTextField,
            stepperUpButton, stepperDownButton,
            feelingsQuestionLabel, feelingsSubtitleLabel
        ] + feelingButtons
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStaticUI()
        setupActions()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !didSetupButtons {
            didSetupButtons = true
            setupFeelingButtons()
        }
    }

    // MARK: - Static UI
    private func setupStaticUI() {
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.backgroundColor = .white

        statusLabel.layer.cornerRadius = 12
        statusLabel.clipsToBounds = true
        applyBadge(.notStarted)

        daysTextField.isUserInteractionEnabled = false
        daysTextField.borderStyle = .none
        daysTextField.layer.borderColor = UIColor.lightGray.cgColor
        daysTextField.layer.borderWidth = 1
        daysTextField.layer.cornerRadius = 10
        daysTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        daysTextField.leftViewMode = .always

        applySaveStyle()
        saveButton.isHidden = false
        saveButton.alpha = 0.4
        saveButton.isUserInteractionEnabled = false

        applyEditStyle()
        editButton.isHidden = true
    }

    // MARK: - Button Styles (legacy API only — no UIButton.Configuration on save/edit)
    private func applySaveStyle() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.backgroundColor = darkPinkColor
        saveButton.layer.cornerRadius = 14
        saveButton.clipsToBounds = true
    }

    private func applyEditStyle() {
        // Only bg + corners — XIB owns title, emoji, font, color
        editButton.backgroundColor = lightPinkColor
        editButton.layer.cornerRadius = 14
        editButton.clipsToBounds = true
        editButton.setTitleColor(darkPinkColor, for: .normal)
    }

    private func setupFeelingButtons() {
        feelingButtons = [
            sadButton, anxiousButton, overwhelmedButton, scaredButton,
            angryButton, numbButton, hopefulButton, calmButton
        ].compactMap { $0 }

        buttonFeelingMap = [:]
        if let b = sadButton         { buttonFeelingMap[b] = "Sad" }
        if let b = anxiousButton     { buttonFeelingMap[b] = "Anxious" }
        if let b = overwhelmedButton { buttonFeelingMap[b] = "Overwhelmed" }
        if let b = scaredButton      { buttonFeelingMap[b] = "Scared" }
        if let b = angryButton       { buttonFeelingMap[b] = "Angry" }
        if let b = numbButton        { buttonFeelingMap[b] = "Numb" }
        if let b = hopefulButton     { buttonFeelingMap[b] = "Hopeful" }
        if let b = calmButton        { buttonFeelingMap[b] = "Calm" }

        for button in feelingButtons {
            button.layer.cornerRadius = 20
            button.clipsToBounds = true
            button.isHidden = false
            button.alpha = 1
            applyDeselectedStyle(to: button)
        }
    }

    // MARK: - Feeling Button Styling
    private func applySelectedStyle(to button: UIButton) {
        let title = buttonFeelingMap[button] ?? ""
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = darkPinkColor
        config.background.cornerRadius = 20
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15)
        ]))
        button.configuration = config
    }

    private func applyDeselectedStyle(to button: UIButton) {
        let title = buttonFeelingMap[button] ?? button.titleLabel?.text ?? ""
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = lightPinkColor
        config.background.cornerRadius = 20
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .foregroundColor: darkPinkColor,
            .font: UIFont.systemFont(ofSize: 15)
        ]))
        button.configuration = config
    }

    // MARK: - Actions
    private func setupActions() {
        stepperUpButton.addTarget(self, action: #selector(stepperUpTapped), for: .touchUpInside)
        stepperDownButton.addTarget(self, action: #selector(stepperDownTapped), for: .touchUpInside)
        [sadButton, anxiousButton, overwhelmedButton, scaredButton,
         angryButton, numbButton, hopefulButton, calmButton].forEach {
            $0?.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        }
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    @objc private func stepperUpTapped() {
        currentDays += 1
        daysTextField.text = "\(currentDays)"
        if isSaved { revertToEdit() }
        updateSaveButtonState()
    }

    @objc private func stepperDownTapped() {
        guard currentDays > 0 else { return }
        currentDays -= 1
        daysTextField.text = currentDays == 0 ? "" : "\(currentDays)"
        if isSaved { revertToEdit() }
        updateSaveButtonState()
    }

    @objc private func feelingButtonTapped(_ sender: UIButton) {
        guard let feeling = buttonFeelingMap[sender] else { return }
        if selectedFeelings.contains(feeling) {
            selectedFeelings.remove(feeling)
            applyDeselectedStyle(to: sender)
        } else {
            selectedFeelings.insert(feeling)
            applySelectedStyle(to: sender)
        }
        if isSaved { revertToEdit() }
        updateSaveButtonState()
    }

    // MARK: - Save
    @objc private func saveButtonTapped() {
        guard currentDays > 0, !selectedFeelings.isEmpty else { return }
        isSaved = true

        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: kSaveDate)
        defaults.set(currentDays, forKey: kDaysInput)
        defaults.set(Array(selectedFeelings), forKey: kFeelings)

        enterSavedState(animated: true)
        onSaveButtonTapped?()
    }

    private func enterSavedState(animated: Bool) {
        refreshCountdownBadge()
        applyEditStyle()

        // Lock interaction
        stepperUpButton.isUserInteractionEnabled = false
        stepperDownButton.isUserInteractionEnabled = false
        feelingButtons.forEach { $0.isUserInteractionEnabled = false }

        let block = {
            // Fade ONLY the form content — title, badge, edit button are NOT in fadableViews
            self.fadableViews.forEach { $0.alpha = 0.35 }
            // Hide save, show edit at FULL alpha
            self.saveButton.isHidden = true
            self.editButton.isHidden = false
            self.editButton.alpha = 1.0   // explicit — never faded
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: block)
        } else {
            block()
        }
    }

    // MARK: - Edit
    @objc private func editButtonTapped() {
        revertToEdit()
    }

    private func revertToEdit() {
        isSaved = false
        applySaveStyle()

        stepperUpButton.isUserInteractionEnabled = true
        stepperDownButton.isUserInteractionEnabled = true
        feelingButtons.forEach { $0.isUserInteractionEnabled = true }

        UIView.animate(withDuration: 0.3) {
            // Restore all form content to full opacity
            self.fadableViews.forEach { $0.alpha = 1.0 }
            // Swap buttons
            self.saveButton.isHidden = false
            self.editButton.isHidden = true
        }

        updateSaveButtonState()
    }

    // MARK: - Countdown Badge
    private func refreshCountdownBadge() {
        guard isSaved else { applyBadge(.notStarted); return }
        let remaining = remainingDays()
        daysTextField.text = remaining > 0 ? "\(remaining)" : "0"
        applyBadge(remaining > 0 ? .inProgress : .completed)
    }

    private func remainingDays() -> Int {
        guard let saveDate = UserDefaults.standard.object(forKey: kSaveDate) as? Date else { return currentDays }
        let daysInput = UserDefaults.standard.integer(forKey: kDaysInput)
        let elapsed = Calendar.current.dateComponents([.day], from: saveDate, to: Date()).day ?? 0
        return max(0, daysInput - elapsed)
    }

    private enum BadgeState { case notStarted, inProgress, completed }

    private func applyBadge(_ state: BadgeState) {
        UIView.animate(withDuration: 0.25) {
            switch state {
            case .notStarted:
                self.statusLabel.text = "Not Started"
                self.statusLabel.backgroundColor = self.notStartedBg
                self.statusLabel.textColor = .gray
            case .inProgress:
                self.statusLabel.text = "In Progress"
                self.statusLabel.backgroundColor = self.inProgressBg
                self.statusLabel.textColor = self.inProgressText
            case .completed:
                self.statusLabel.text = "Completed"
                self.statusLabel.backgroundColor = self.savedGreenBg
                self.statusLabel.textColor = self.savedGreenColor
            }
        }
    }

    // MARK: - Save Button State
    private func updateSaveButtonState() {
        let shouldEnable = currentDays > 0 && !selectedFeelings.isEmpty
        saveButton.isUserInteractionEnabled = shouldEnable
        UIView.animate(withDuration: 0.2) {
            self.saveButton.alpha = shouldEnable ? 1.0 : 0.4
        }
    }

    // MARK: - Height
    func getCellHeight() -> CGFloat { return 510 }

    // MARK: - Configure
    func configure(with model: WaitModel) {
        stepperUpButton.isUserInteractionEnabled = true
        stepperDownButton.isUserInteractionEnabled = true

        let wasSaved = UserDefaults.standard.object(forKey: kSaveDate) != nil
        if wasSaved {
            isSaved = true
            currentDays = remainingDays()
            daysTextField.text = currentDays > 0 ? "\(currentDays)" : "0"
            if let feelings = UserDefaults.standard.array(forKey: kFeelings) as? [String] {
                selectedFeelings = Set(feelings)
            }
            updateFeelingButtonStates()
            enterSavedState(animated: false)
        } else {
            isSaved = false
            applyBadge(.notStarted)
            applySaveStyle()
            saveButton.isHidden = false
            saveButton.alpha = 0.4
            saveButton.isUserInteractionEnabled = false
            editButton.isHidden = true
            // Restore full opacity in case of cell reuse
            fadableViews.forEach { $0.alpha = 1.0 }

            if let days = model.daysWaited {
                currentDays = days
                daysTextField.text = "\(days)"
            }
            selectedFeelings = model.selectedFeelings
            updateFeelingButtonStates()
            updateSaveButtonState()
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func updateFeelingButtonStates() {
        for (button, feeling) in buttonFeelingMap {
            if selectedFeelings.contains(feeling) {
                applySelectedStyle(to: button)
            } else {
                applyDeselectedStyle(to: button)
            }
        }
    }
}
