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
    
    // New outlets for button and message
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var successMessageView: UIView!
    @IBOutlet weak var successMessageLabel: UILabel!
    
    // MARK: - Properties
    private var overlayView: UIView?
    private var datePickerContainerView: UIView?
    var onDateSelected: ((Date) -> Void)?
    var onSaveButtonTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Hide the XIB date picker
        datePicker.isHidden = true
        datePickerHeightConstraint.constant = 0
        
        // Disable text field direct editing
        dateTextField.isUserInteractionEnabled = false
        
        // Initially hide button and message
        saveButton.isHidden = true
        successMessageView.isHidden = true
        
        // Setup container view appearance
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        // Add rounded corners to status label
        statusLabel.layer.cornerRadius = 12
        statusLabel.clipsToBounds = true
        
        // Setup save button appearance
        saveButton.backgroundColor = UIColor(red: 0.93, green: 0.45, blue: 0.64, alpha: 1.0) // Pink color
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
    }
    
    private func setupActions() {
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        showDatePickerOverlay()
    }
    
    private func showDatePickerOverlay() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        // Create overlay background (dimmed)
        overlayView = UIView(frame: window.bounds)
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView?.alpha = 0
        
        // Tap to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker))
        overlayView?.addGestureRecognizer(tapGesture)
        
        // Create date picker container
        datePickerContainerView = UIView()
        datePickerContainerView?.backgroundColor = .white
        datePickerContainerView?.layer.cornerRadius = 16
        datePickerContainerView?.translatesAutoresizingMaskIntoConstraints = false
        
        // Create new date picker for overlay
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        // Create Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(dismissDatePicker), for: .touchUpInside)
        
        // Add to container
        datePickerContainerView?.addSubview(picker)
        datePickerContainerView?.addSubview(doneButton)
        
        // Add to window
        window.addSubview(overlayView!)
        window.addSubview(datePickerContainerView!)
        
        // Constraints for date picker container
        NSLayoutConstraint.activate([
            datePickerContainerView!.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            datePickerContainerView!.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            datePickerContainerView!.widthAnchor.constraint(equalToConstant: 350),
            
            picker.topAnchor.constraint(equalTo: datePickerContainerView!.topAnchor, constant: 20),
            picker.leadingAnchor.constraint(equalTo: datePickerContainerView!.leadingAnchor, constant: 10),
            picker.trailingAnchor.constraint(equalTo: datePickerContainerView!.trailingAnchor, constant: -10),
            
            doneButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10),
            doneButton.centerXAnchor.constraint(equalTo: datePickerContainerView!.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: datePickerContainerView!.bottomAnchor, constant: -20),
            doneButton.widthAnchor.constraint(equalToConstant: 100),
            doneButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Animate in
        datePickerContainerView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        datePickerContainerView?.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.overlayView?.alpha = 1
            self.datePickerContainerView?.alpha = 1
            self.datePickerContainerView?.transform = .identity
        }
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
        
        // Show save button, hide success message
        saveButton.isHidden = false
        successMessageView.isHidden = true
        
        // Notify the view controller
        onDateSelected?(sender.date)
        onCellHeightChanged?()
    }
    
    @objc private func saveButtonTapped() {
        // Hide save button
        saveButton.isHidden = true
        
        // Show success message
        successMessageView.isHidden = false
        
        // Update status to "Completed"
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0) // Light green
        statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0) // Dark green
        
        // Notify VC
        onSaveButtonTapped?()
        onCellHeightChanged?()
    }
    
    func getCellHeight() -> CGFloat {
        if !successMessageView.isHidden {
            return 300 // Increased for success message
        } else if !saveButton.isHidden {
            return 310 // Increased for save button
        } else {
            return 240 // Increased base height
        }
    }
    // MARK: - Configuration
    func configure(with model: DiagnosisModel) {
        statusLabel.text = model.status
        
        // Update status appearance
        if model.status == "Completed" {
            statusLabel.backgroundColor = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
            successMessageView.isHidden = false
            saveButton.isHidden = true
        } else {
            statusLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            statusLabel.textColor = .gray
            successMessageView.isHidden = true
            saveButton.isHidden = true
        }
        
        if let date = model.diagnosisDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            dateTextField.text = formatter.string(from: date)
        }
    }
}
