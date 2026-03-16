import UIKit

class DiagnosisCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var diagnosisDateLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    // MARK: - Properties
    private let pink      = UIColor(named: "pink")      ?? UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let lightPink = UIColor(named: "lightPink") ?? UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)
    private var overlayView: UIView?
    private var datePickerContainerView: UIView?
    private var isSaved = false

    private var lockOverlayView: UIView?

    // MARK: - Persistence
    private let kDiagnosisDate   = "diagnosisCell_date"
    private let kDiagnosisStatus = "diagnosisCell_status"

    var onDateSelected: ((Date) -> Void)?
    var onSaveButtonTapped: (() -> Void)?
    var onEditButtonTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupActions()
    }

    // MARK: - Setup
    private func setupUI() {
        datePicker.isHidden = true
        datePickerHeightConstraint.constant = 0

        dateTextField.isUserInteractionEnabled = false
        dateTextField.borderStyle = .none
        dateTextField.layer.borderColor = UIColor.lightGray.cgColor
        dateTextField.layer.borderWidth = 1
        dateTextField.layer.cornerRadius = 10
        dateTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        dateTextField.leftViewMode = .always

        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4

        statusLabel.layer.cornerRadius = 12
        statusLabel.clipsToBounds = true

        applySaveButtonStyle()
        saveButton.isHidden = false
        saveButton.alpha = 0.4
        saveButton.isUserInteractionEnabled = false

        applyEditButtonStyle()
        editButton.isHidden = true
    }

    // MARK: - Lock Overlay
    func setLocked(_ locked: Bool) {
        if locked {
            showLockOverlay()
        } else {
            removeLockOverlay()
        }
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

        containerView.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: containerView.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        lockOverlayView = overlay
    }

    private func removeLockOverlay() {
        lockOverlayView?.removeFromSuperview()
        lockOverlayView = nil
    }

    // MARK: - Button Styles
    private func applySaveButtonStyle() {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = pink
        config.background.cornerRadius = 14
        config.attributedTitle = AttributedString(
            "Save",
            attributes: AttributeContainer([
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ])
        )
        saveButton.configuration = config
    }

    private func applyEditButtonStyle() {
        editButton.backgroundColor = lightPink
        editButton.layer.cornerRadius = 14
        editButton.clipsToBounds = true
        editButton.setTitleColor(pink, for: .normal)
    }

    private func setupActions() {
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    // MARK: - Save
    @objc private func saveButtonTapped() {
        isSaved = true
        if let text = dateTextField.text, !text.isEmpty {
            UserDefaults.standard.set(text, forKey: kDiagnosisDate)
        }
        UserDefaults.standard.set("Completed", forKey: kDiagnosisStatus)

        statusLabel.text = "Completed"
        statusLabel.backgroundColor = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
        statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        enterSavedState(animated: true)
        onSaveButtonTapped?()
    }

    private func enterSavedState(animated: Bool) {
        applyEditButtonStyle()
        let block = {
            self.diagnosisDateLabel.alpha = 0.35
            self.dateTextField.alpha = 0.35
            self.calendarButton.alpha = 0.0
            self.saveButton.isHidden = true
            self.editButton.isHidden = false
        }
        animated ? UIView.animate(withDuration: 0.3, animations: block) : block()
    }

    // MARK: - Edit
    @objc private func editButtonTapped() {
        UserDefaults.standard.removeObject(forKey: kDiagnosisDate)
        UserDefaults.standard.removeObject(forKey: kDiagnosisStatus)
        enterEditState(animated: true)
        onEditButtonTapped?()
    }

    private func enterEditState(animated: Bool) {
        isSaved = false
        let hasDate = !(dateTextField.text?.isEmpty ?? true)
        applySaveButtonStyle()
        let block = {
            self.diagnosisDateLabel.alpha = 1.0
            self.dateTextField.alpha = 1.0
            self.calendarButton.alpha = 1.0
            self.saveButton.isHidden = false
            self.saveButton.alpha = hasDate ? 1.0 : 0.4
            self.editButton.isHidden = true
        }
        animated ? UIView.animate(withDuration: 0.3, animations: block) : block()
        saveButton.isUserInteractionEnabled = hasDate
        statusLabel.text = "Not Started"
        statusLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        statusLabel.textColor = .gray
    }

    // MARK: - Calendar
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        showDatePickerOverlay()
    }

    private func showDatePickerOverlay() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        overlayView = UIView(frame: window.bounds)
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView?.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker))
        overlayView?.addGestureRecognizer(tapGesture)

        datePickerContainerView = UIView()
        datePickerContainerView?.backgroundColor = .white
        datePickerContainerView?.layer.cornerRadius = 16
        datePickerContainerView?.translatesAutoresizingMaskIntoConstraints = false

        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.tintColor = pink
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

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
        doneButton.addTarget(self, action: #selector(dismissDatePicker), for: .touchUpInside)

        buttonStack.addArrangedSubview(resetButton)
        buttonStack.addArrangedSubview(doneButton)

        datePickerContainerView?.addSubview(picker)
        datePickerContainerView?.addSubview(buttonStack)
        window.addSubview(overlayView!)
        window.addSubview(datePickerContainerView!)

        NSLayoutConstraint.activate([
            datePickerContainerView!.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            datePickerContainerView!.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            datePickerContainerView!.widthAnchor.constraint(equalToConstant: 350),
            picker.topAnchor.constraint(equalTo: datePickerContainerView!.topAnchor, constant: 20),
            picker.leadingAnchor.constraint(equalTo: datePickerContainerView!.leadingAnchor, constant: 10),
            picker.trailingAnchor.constraint(equalTo: datePickerContainerView!.trailingAnchor, constant: -10),
            buttonStack.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10),
            buttonStack.leadingAnchor.constraint(equalTo: datePickerContainerView!.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: datePickerContainerView!.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: datePickerContainerView!.bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])

        datePickerContainerView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        datePickerContainerView?.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.overlayView?.alpha = 1
            self.datePickerContainerView?.alpha = 1
            self.datePickerContainerView?.transform = .identity
        }
    }

    @objc private func resetDateTapped() {
        dateTextField.text = nil
        onDateSelected?(Date.distantPast)
        saveButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) { self.saveButton.alpha = 0.4 }
        dismissDatePicker()
    }

    @objc private func dismissDatePicker() {
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

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateTextField.text = formatter.string(from: sender.date)
        onDateSelected?(sender.date)
        saveButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2) { self.saveButton.alpha = 1.0 }
    }

    // MARK: - Height
    func getCellHeight() -> CGFloat { return 240 }

    // MARK: - Configure
    func configure(with model: DiagnosisModel) {
        let savedStatus = UserDefaults.standard.string(forKey: kDiagnosisStatus)
        let savedDateString = UserDefaults.standard.string(forKey: kDiagnosisDate)

        if let dateString = savedDateString {
            dateTextField.text = dateString
        } else if let date = model.diagnosisDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            dateTextField.text = formatter.string(from: date)
        }

        if savedStatus == "Completed" || model.status == "Completed" {
            isSaved = true
            statusLabel.text = "Completed"
            statusLabel.backgroundColor = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
            applyEditButtonStyle()
            enterSavedState(animated: false)
        } else {
            statusLabel.text = "Not Started"
            statusLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            statusLabel.textColor = .gray
            let hasDate = !(dateTextField.text?.isEmpty ?? true)
            applySaveButtonStyle()
            saveButton.alpha = hasDate ? 1.0 : 0.4
            saveButton.isUserInteractionEnabled = hasDate
            editButton.isHidden = true
            saveButton.isHidden = false
        }
    }
}
