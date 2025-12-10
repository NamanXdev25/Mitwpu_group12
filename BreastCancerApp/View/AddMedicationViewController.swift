import UIKit

// This protocol allows us to send the new pill data back to the List Screen
protocol AddMedicationDelegate: AnyObject {
    func didAddMedication(name: String, time: String, repeatOption: String, note: String)
}

class AddMedicationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    // --- OUTLETS ---
    @IBOutlet weak var CloseButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    // --- PICKER OUTLETS ---
    @IBOutlet weak var pickerOverlay: UIView!
    @IBOutlet weak var pickerCard: UIView!
    @IBOutlet weak var repeatPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    weak var delegate: AddMedicationDelegate?
    
    let weekDays = ["Every Mon", "Every Tue", "Every Wed", "Every Thu", "Every Fri", "Every Sat", "Every Sun", "Every Day"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Delegates
        nameTextField.delegate = self
        repeatTextField.delegate = self
        timeTextField.delegate = self
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
        descriptionTextView.delegate = self
        
        // Setup Time Picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        
        // Setup Pickers (Hidden initially)
        pickerOverlay.isHidden = true
        
        // Add Tap to Dismiss Overlay
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        pickerOverlay.addGestureRecognizer(tapGesture)
        
        // Add Chevrons
        addChevron(to: repeatTextField)
        addChevron(to: timeTextField)
    }
    
    func setupUI() {
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        pickerCard.layer.cornerRadius = 16
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.backgroundColor = UIColor.systemGray6
        descriptionTextView.text = "Add a note"
        descriptionTextView.textColor = .lightGray
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
    }

    // --- LOGIC TO SHOW PICKERS ---
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == repeatTextField {
            view.endEditing(true)
            pickerOverlay.isHidden = false
            repeatPicker.isHidden = false
            timePicker.isHidden = true
            return false
        } else if textField == timeTextField {
            view.endEditing(true)
            pickerOverlay.isHidden = false
            repeatPicker.isHidden = true
            timePicker.isHidden = false
            return false
        }
        return true
    }
    
    @objc func dismissPopup() {
        if !repeatPicker.isHidden {
            let row = repeatPicker.selectedRow(inComponent: 0)
            repeatTextField.text = weekDays[row]
        } else if !timePicker.isHidden {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            timeTextField.text = formatter.string(from: timePicker.date)
        }
        pickerOverlay.isHidden = true
    }
    
    // --- ACTIONS ---
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        // 1. Get the data
        guard let name = nameTextField.text, !name.isEmpty else { return }
        let time = timeTextField.text ?? "10:00 AM"
        let repeatOption = repeatTextField.text ?? "Every Day"
        let note = (descriptionTextView.text == "Add a note") ? "" : descriptionTextView.text
        
        // 2. Send it to the List Screen
        delegate?.didAddMedication(name: name, time: time, repeatOption: repeatOption, note: note ?? "")
        
        // 3. Close the Modal
        self.dismiss(animated: true)
    }
    
    // --- HELPERS ---
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { weekDays.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { weekDays[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repeatTextField.text = weekDays[row]
    }
    
    func addChevron(to textField: UITextField) {
        let iconView = UIImageView(image: UIImage(systemName: "chevron.down"))
        iconView.tintColor = .lightGray
        iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        iconView.contentMode = .scaleAspectFit
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        container.addSubview(iconView)
        textField.rightView = container
        textField.rightViewMode = .always
    }
    
    // TextView Placeholder Logic
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a note"
            textView.textColor = .lightGray
        }
    }
}
