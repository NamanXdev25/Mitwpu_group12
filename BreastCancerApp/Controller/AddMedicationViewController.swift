import UIKit

protocol AddMedicationDelegate: AnyObject {
    func didAddMedication(name: String, time: String, repeatOption: String, note: String, reminderEnabled: Bool)
    func didEditMedication(index: Int, name: String, time: String, repeatOption: String, note: String, reminderEnabled: Bool)
}

class AddMedicationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    // MARK: - Outlets

    @IBOutlet var closeBarButton: UIBarButtonItem!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var repeatTextField: UITextField!
    @IBOutlet var timeTextField: UITextField!
    @IBOutlet var reminderSwitch: UISwitch!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var saveBarButton: UIBarButtonItem!

    @IBOutlet var repeatChevronImageView: UIImageView!
    @IBOutlet var timeChevronImageView: UIImageView!

    @IBOutlet var pickerOverlay: UIView!
    @IBOutlet var pickerCard: UIView!
    @IBOutlet var repeatPicker: UIPickerView!
    @IBOutlet var timePicker: UIDatePicker!

    // MARK: - Properties

    weak var delegate: AddMedicationDelegate?

    var medicationToEdit: Medication?
    var indexToEdit: Int?

    let repeatOptions = ["Every Day", "Every Mon", "Every Tue", "Every Wed", "Every Thu", "Every Fri", "Every Sat", "Every Sun"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupChevronTapGestures()
        setupPickerOverlay()

        if let med = medicationToEdit {
            nameTextField.text = med.name
            repeatTextField.text = med.repeatOption
            repeatTextField.textColor = .black
            timeTextField.text = med.time
            noteTextView.text = med.note.isEmpty ? "Add a note (optional)" : med.note
            noteTextView.textColor = med.note.isEmpty ? .lightGray : .black
            reminderSwitch.isOn = med.reminderEnabled
            title = "Edit Medication"

            if let index = repeatOptions.firstIndex(of: med.repeatOption) {
                repeatPicker.selectRow(index, inComponent: 0, animated: false)
            }
        } else {
            title = "Add Medication"
            repeatTextField.text = "Every Day"
            repeatTextField.textColor = .lightGray
            reminderSwitch.isOn = true
        }
    }

    // MARK: - Setup Methods

    func setupUI() {
        if medicationToEdit == nil {
            noteTextView.text = "Add a note (optional)"
            noteTextView.textColor = .lightGray
        }
        noteTextView.delegate = self

        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "en_US")
    }

    func setupDelegates() {
        nameTextField.delegate = self
        repeatTextField.delegate = self
        timeTextField.delegate = self
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
    }

    func setupChevronTapGestures() {
        repeatChevronImageView.isUserInteractionEnabled = true
        timeChevronImageView.isUserInteractionEnabled = true

        let repeatTap = UITapGestureRecognizer(target: self, action: #selector(repeatChevronTapped))
        repeatChevronImageView.addGestureRecognizer(repeatTap)

        let timeTap = UITapGestureRecognizer(target: self, action: #selector(timeChevronTapped))
        timeChevronImageView.addGestureRecognizer(timeTap)
    }

    func setupPickerOverlay() {
        pickerOverlay.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        pickerOverlay.addGestureRecognizer(tapGesture)
    }

    // MARK: - Chevron Actions

    @objc func repeatChevronTapped() {
        showRepeatPicker()
    }

    @objc func timeChevronTapped() {
        showTimePicker()
    }

    // MARK: - TextField Delegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == repeatTextField {
            showRepeatPicker()
            return false
        } else if textField == timeTextField {
            showTimePicker()
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Picker Display Methods

    func showRepeatPicker() {
        view.endEditing(true)

        if let currentText = repeatTextField.text,
           let index = repeatOptions.firstIndex(of: currentText) {
            repeatPicker.selectRow(index, inComponent: 0, animated: false)
        }

        pickerOverlay.isHidden = false
        repeatPicker.isHidden = false
        timePicker.isHidden = true
    }

    func showTimePicker() {
        view.endEditing(true)
        pickerOverlay.isHidden = false
        repeatPicker.isHidden = true
        timePicker.isHidden = false
    }

    @objc func dismissPopup() {
        if !repeatPicker.isHidden {
            let selectedRow = repeatPicker.selectedRow(inComponent: 0)
            repeatTextField.text = repeatOptions[selectedRow]
            repeatTextField.textColor = .black
        } else if !timePicker.isHidden {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            timeTextField.text = formatter.string(from: timePicker.date)
        }
        pickerOverlay.isHidden = true
    }

    // MARK: - UIPickerView DataSource & Delegate

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return repeatOptions.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return repeatOptions[row]
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        repeatTextField.text = repeatOptions[row]
        repeatTextField.textColor = .black
    }

    // MARK: - Actions

    @IBAction func closeTapped(_: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func saveTapped(_: UIBarButtonItem) {
        saveMedication()
    }

    func saveMedication() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            showAlert(message: "Please enter a medication name.")
            return
        }
        guard let repeatText = repeatTextField.text, !repeatText.isEmpty else {
            showAlert(message: "Please select how often to take this medication.")
            return
        }
        guard let time = timeTextField.text, !time.isEmpty else {
            showAlert(message: "Please select a time.")
            return
        }
        var note = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if note == "Add a note (optional)" {
            note = ""
        }
        let reminderEnabled = reminderSwitch.isOn

        if let index = indexToEdit {
            delegate?.didEditMedication(index: index, name: name, time: time, repeatOption: repeatText, note: note, reminderEnabled: reminderEnabled)
        } else {
            delegate?.didAddMedication(name: name, time: time, repeatOption: repeatText, note: note, reminderEnabled: reminderEnabled)
        }

        navigationController?.popViewController(animated: true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Required Field", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension AddMedicationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a note (optional)"
            textView.textColor = UIColor.lightGray
        }
    }
}
