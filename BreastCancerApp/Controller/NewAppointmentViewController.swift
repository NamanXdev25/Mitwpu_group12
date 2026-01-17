//
//  NewAppointmentViewController.swift
//  Appointments
//
//  Created by Naman Bhansali on 10/01/26.
//

import UIKit

// MARK: - Protocol
protocol AddAppointmentDelegate: AnyObject {
    func didAddAppointment(_ appointment: AppointmentItem)
}

// MARK: - View Controller
class NewAppointmentViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var userTitleTextField: UITextField! 
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var chemotherapyIndicatorView: UIView!
    @IBOutlet weak var doctorVisitIndicatorView: UIView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var setReminderSwitch: UISwitch!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var categoryChevronImageView: UIImageView!
    @IBOutlet weak var dateChevronImageView: UIImageView!
    @IBOutlet weak var timeChevronImageView: UIImageView!
    
    @IBOutlet weak var pickerOverlay: UIView!
    @IBOutlet weak var pickerCard: UIView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    // MARK: - Properties
    weak var delegate: AddAppointmentDelegate?
    
    var initialAppointment: AppointmentItem?
    var originalDate: Date?
    
    private var selectedAppointmentType: AppointmentType = .chemotherapy
    private let notePlaceholder = "Add a note"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupGestures()
        loadInitialData()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        setupPickerCard()
        setupNoteTextView()
        setupTitleIndicator()
        setupPickers()
        setupCategoryTextField()
        pickerOverlay.isHidden = true
    }
    
    private func setupPickerCard() {
        pickerCard.layer.shadowColor = UIColor.black.cgColor
        pickerCard.layer.shadowOpacity = 0.2
        pickerCard.layer.shadowRadius = 10
    }
    
    private func setupNoteTextView() {
        noteTextView.text = notePlaceholder
        noteTextView.textColor = .lightGray
        noteTextView.delegate = self
        noteTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
    }
    
    private func setupTitleIndicator() {
        chemotherapyIndicatorView.layer.cornerRadius = chemotherapyIndicatorView.frame.width / 2
        chemotherapyIndicatorView.clipsToBounds = true
        chemotherapyIndicatorView.backgroundColor = AppointmentType.chemotherapy.color
        
        doctorVisitIndicatorView.layer.cornerRadius = doctorVisitIndicatorView.frame.width / 2
        doctorVisitIndicatorView.clipsToBounds = true
        doctorVisitIndicatorView.backgroundColor = AppointmentType.doctorVisit.color
        
        updateIndicatorVisibility()
    }
    
    private func setupCategoryTextField() {
        categoryTextField.textColor = .lightGray
        categoryTextField.isUserInteractionEnabled = true
    }
    
    private func setupPickers() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        datePicker.locale = Locale(identifier: "en_US")
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "en_US")
    }
    
    private func setupDelegates() {
        userTitleTextField.delegate = self
        categoryTextField.delegate = self
        dateTextField.delegate = self
        timeTextField.delegate = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    private func setupGestures() {
        setupChevronTapGestures()
        setupOverlayTapGesture()
    }
    
    private func setupChevronTapGestures() {
        categoryChevronImageView.isUserInteractionEnabled = true
        dateChevronImageView.isUserInteractionEnabled = true
        timeChevronImageView.isUserInteractionEnabled = true
        
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(categoryChevronTapped))
        categoryChevronImageView.addGestureRecognizer(categoryTap)
        
        let dateTap = UITapGestureRecognizer(target: self, action: #selector(dateChevronTapped))
        dateChevronImageView.addGestureRecognizer(dateTap)
        
        let timeTap = UITapGestureRecognizer(target: self, action: #selector(timeChevronTapped))
        timeChevronImageView.addGestureRecognizer(timeTap)
    }
    
    private func setupOverlayTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        pickerOverlay.addGestureRecognizer(tapGesture)
    }
    
    private func loadInitialData() {
        guard let appointment = initialAppointment else {
            setDefaultValues()
            return
        }
        
        loadAppointmentData(appointment)
    }
    
    private func setDefaultValues() {
        categoryTextField.text = AppointmentType.chemotherapy.title
        categoryTextField.textColor = .lightGray
        updateIndicatorVisibility()
    }
    
    private func loadAppointmentData(_ appointment: AppointmentItem) {
        // Load custom title
        userTitleTextField.text = appointment.title
        userTitleTextField.textColor = .black
        
        // Load category
        if let type = AppointmentType(rawValue: appointment.colorIndex) {
            selectedAppointmentType = type
            categoryTextField.text = type.title
            categoryTextField.textColor = .black
            updateIndicatorVisibility()
        }
        
        // Load date
        if !appointment.date.isEmpty {
            dateTextField.text = appointment.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            if let parsedDate = formatter.date(from: appointment.date) {
                datePicker.date = parsedDate
                originalDate = parsedDate
            }
        }
        
        dateTextField.isUserInteractionEnabled = true
        dateTextField.textColor = .black
        dateTextField.backgroundColor = .clear
        dateChevronImageView.isHidden = false
        
        // Load time
        if !appointment.time.isEmpty {
            timeTextField.text = appointment.time
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            if let parsedTime = formatter.date(from: appointment.time) {
                timePicker.date = parsedTime
            }
        }
        
        // Load note
        if !appointment.note.isEmpty {
            noteTextView.text = appointment.note
            noteTextView.textColor = .black
        }
        
        setReminderSwitch.isOn = appointment.reminderEnabled
    }
    
    // MARK: - UI Update Methods
    private func updateIndicatorVisibility() {
        switch selectedAppointmentType {
        case .chemotherapy:
            chemotherapyIndicatorView.isHidden = false
            doctorVisitIndicatorView.isHidden = true
        case .doctorVisit:
            chemotherapyIndicatorView.isHidden = true
            doctorVisitIndicatorView.isHidden = false
        }
    }
    
    private func showPicker(category: Bool = false, date: Bool = false, time: Bool = false) {
        view.endEditing(true)
        pickerOverlay.isHidden = false
        
        categoryPicker.isHidden = !category
        datePicker.isHidden = !date
        timePicker.isHidden = !time
        
        if category {
            categoryPicker.selectRow(selectedAppointmentType.rawValue, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Gesture Actions
    @objc private func categoryChevronTapped() {
        showPicker(category: true)
    }
    
    @objc private func dateChevronTapped() {
        showPicker(date: true)
    }
    
    @objc private func timeChevronTapped() {
        showPicker(time: true)
    }
    
    @objc private func dismissPopup() {
        if !categoryPicker.isHidden {
            handleCategoryPickerDismiss()
        } else if !datePicker.isHidden {
            handleDatePickerDismiss()
        } else if !timePicker.isHidden {
            handleTimePickerDismiss()
        }
        
        pickerOverlay.isHidden = true
    }
    
    private func handleCategoryPickerDismiss() {
        let selectedRow = categoryPicker.selectedRow(inComponent: 0)
        if let type = AppointmentType(rawValue: selectedRow) {
            selectedAppointmentType = type
            categoryTextField.text = type.title
            categoryTextField.textColor = .black
            updateIndicatorVisibility()
        }
    }
    
    private func handleDatePickerDismiss() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    private func handleTimePickerDismiss() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeTextField.text = formatter.string(from: timePicker.date)
    }
    
    // MARK: - IBActions
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard validateInputs() else { return }
        
        if let appointment = initialAppointment, let oldDate = originalDate {
            let newDateString = dateTextField.text ?? ""
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            
            if let newDate = formatter.date(from: newDateString) {
                let calendar = Calendar.current
                if !calendar.isDate(oldDate, inSameDayAs: newDate) {
                    AppointmentManager.shared.deleteAppointment(appointment.id, for: oldDate)
                }
            }
        }
        
        let appointment = createAppointment()
        delegate?.didAddAppointment(appointment)
        dismiss(animated: true)
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        // Validate Title
        guard let title = userTitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showAlert(message: "Please enter a title for the appointment.")
            return false
        }
        
        // Validate Category
        guard let category = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !category.isEmpty,
              categoryTextField.textColor != .lightGray else {
            showAlert(message: "Please select a category.")
            return false
        }
        
        // Validate Date
        guard let date = dateTextField.text, !date.isEmpty else {
            showAlert(message: "Please select a date for the appointment.")
            return false
        }
        
        // Validate Time
        guard let time = timeTextField.text, !time.isEmpty else {
            showAlert(message: "Please select a time for the appointment.")
            return false
        }
        
        return true
    }
    
    // MARK: - Model Creation
    private func createAppointment() -> AppointmentItem {
        let appointmentId = initialAppointment?.id ?? UUID().uuidString
        let userTitle = userTitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let category = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let date = dateTextField.text ?? ""
        let time = timeTextField.text ?? ""
        let note = getNoteText()
        
        return AppointmentItem(
            id: appointmentId,
            title: userTitle,
            category: category,
            date: date,
            time: time,
            reminderEnabled: setReminderSwitch.isOn,
            note: note,
            colorIndex: selectedAppointmentType.rawValue
        )
    }
    
    private func getNoteText() -> String {
        let text = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text == notePlaceholder ? "" : text
    }
    
    // MARK: - Alert
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Required Field",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension NewAppointmentViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == categoryTextField {
            showPicker(category: true)
            return false
        } else if textField == dateTextField {
            showPicker(date: true)
            return false
        } else if textField == timeTextField {
            showPicker(time: true)
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension NewAppointmentViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppointmentType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AppointmentType(rawValue: row)?.pickerTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let type = AppointmentType(rawValue: row) {
            selectedAppointmentType = type
            categoryTextField.text = type.title
            categoryTextField.textColor = .black
            updateIndicatorVisibility()
        }
    }
}

// MARK: - UITextViewDelegate
extension NewAppointmentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = notePlaceholder
            textView.textColor = .lightGray
        }
    }
}
