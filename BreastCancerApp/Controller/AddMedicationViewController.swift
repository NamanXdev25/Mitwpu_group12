//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Shloka Shetty on 3/12/25.
//
import UIKit

// This protocol allows us to send the new pill data back to the List Screen
protocol AddMedicationDelegate: AnyObject {
    func didAddMedication(name: String, time: String, repeatOption: String, note: String)
    
    // NEW: Function to handle updates
    func didEditMedication(index: Int, name: String, time: String, repeatOption: String, note: String)
}

class AddMedicationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    //Mark:- --- OUTLETS ---
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
    
    // --- NEW VARIABLES FOR EDITING ---
    var medicationToEdit: Medication?
    var indexToEdit: Int?
    
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
        self.title = "Edit Details"
        
        // Setup Time Picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        
        // Setup Pickers (Hidden initially)≠≠≠≠
        pickerOverlay.isHidden = true
        
        // Add Tap to Dismiss Overlay
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        pickerOverlay.addGestureRecognizer(tapGesture)
        
        // Add Chevrons
        addChevron(to: repeatTextField)
        addChevron(to: timeTextField)
        
        // --- NEW: PRE-FILL DATA IF EDITING ---
        checkForEditMode()
    }
    
    func setupUI() {
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        pickerCard.layer.cornerRadius = 16
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.backgroundColor = UIColor.systemGray6
        
        // Default State
        descriptionTextView.text = "Add a note"
        descriptionTextView.textColor = .lightGray
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
    }

    // --- NEW: POPULATE FIELDS ---
    func checkForEditMode() {
            if let med = medicationToEdit {
                // 1. Update Title
                self.title = "Edit Details"
                
                // 2. Update Pink Button (Arrow Only)
                saveButton.setTitle("", for: .normal) // Remove text
                saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal) 
                saveButton.tintColor = .white
                
                // 3. Fill Fields
                nameTextField.text = med.name
                timeTextField.text = med.time
                
                // 4. Handle Description/Note
                if weekDays.contains(med.note) {
                    repeatTextField.text = med.note
                    descriptionTextView.text = "Add a note"
                    descriptionTextView.textColor = .lightGray
                } else {
                    repeatTextField.text = "Every Day"
                    descriptionTextView.text = med.note
                    descriptionTextView.textColor = .black
                }
            }
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
        let note = (descriptionTextView.text == "Add a note") ? "" : descriptionTextView.text ?? ""
        
        // 2. CHECK: ARE WE EDITING OR ADDING?
        if let index = indexToEdit {
            // We are EDITING
            delegate?.didEditMedication(index: index, name: name, time: time, repeatOption: repeatOption, note: note)
        } else {
            // We are ADDING
            delegate?.didAddMedication(name: name, time: time, repeatOption: repeatOption, note: note)
        }
        
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
        // Create a small container view for the icon
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        
        // Create the image view
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        iconView.image = UIImage(systemName: "chevron.up.chevron.down") // Or just "chevron.down"
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .lightGray
        
        iconContainer.addSubview(iconView)
        
        // Add tap gesture to the container to ensure tapping the icon opens the picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chevronTapped(_:)))
        iconContainer.addGestureRecognizer(tapGesture)
        iconContainer.isUserInteractionEnabled = true
        
        // Store reference to text field in the container's tag or accessibilityIdentifier if needed,
        // but since we are inside a closure-like scope, we can just use the textField reference if we were defining the action here.
        // Instead, we will attach the text field to the gesture recognizer's view via a simple associated object trick or just rely on the fact that rightView touches often pass through.
        // A cleaner way is to make the icon container pass touches to the text field.
        
        // Set it as the right view of the text field
        textField.rightView = iconContainer
        textField.rightViewMode = .always
        
        // Associate the text field with the gesture logic
        iconContainer.accessibilityElements = [textField]
    }
    
    @objc func chevronTapped(_ sender: UITapGestureRecognizer) {
        // Find which text field this chevron belongs to
        if let container = sender.view, let textField = container.accessibilityElements?.first as? UITextField {
            textField.becomeFirstResponder()
        }
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
