//
//  AddExerciseViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 29/11/25.
//


import UIKit

protocol AddExerciseDelegate: AnyObject {
    func didAddExercise(_ exercise: PlanItem)
}

class AddExerciseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // --- FORM OUTLETS ---
    @IBOutlet weak var CloseButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    // --- POPUP OUTLETS ---
    @IBOutlet weak var pickerOverlay: UIView!   // The dark background
    @IBOutlet weak var pickerCard: UIView!      // The white box
    @IBOutlet weak var repeatPicker: UIPickerView! // Channel 1
    @IBOutlet weak var timePicker: UIDatePicker!   // Channel 2
    
    weak var delegate: AddExerciseDelegate?
    
    let weekDays = ["Every Mon", "Every Tue", "Every Wed", "Every Thu", "Every Fri", "Every Sat", "Every Sun", "Every Day"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 1. Set Delegates
        nameTextField.delegate = self
        repeatTextField.delegate = self
        timeTextField.delegate = self
        
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
        
        // --- FIX: FORCE TIME ONLY ---
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "en_US") // Optional: Forces AM/PM style
        
        addChevron(to: repeatTextField)
        addChevron(to: timeTextField)
        
        // 2. Setup Overlay (Start with everything HIDDEN)
        pickerOverlay.isHidden = true
        
        // 3. Add Tap Gesture to background (to close popup)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        pickerOverlay.addGestureRecognizer(tapGesture)
    }
    
    func setupUI() {
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.backgroundColor = UIColor(red: 0.85, green: 0.4, blue: 0.5, alpha: 1.0)
        
        // Style the popup card
        pickerCard.layer.cornerRadius = 16
        pickerCard.layer.shadowColor = UIColor.black.cgColor
        pickerCard.layer.shadowOpacity = 0.2
        pickerCard.layer.shadowRadius = 10
        
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.backgroundColor = UIColor.systemGray6
        descriptionTextView.text = "Add a description"
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.textColor = .lightGray
        descriptionTextView.delegate = self // Delegate is handled in extension below
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
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
    
    // --- MAGIC: INTERCEPT TEXT FIELD TAPS ---
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == repeatTextField {
            // User tapped "Repeat" -> Show Channel 1
            showRepeatPicker()
            return false // Prevent standard keyboard
        }
        else if textField == timeTextField {
            // User tapped "Time" -> Show Channel 2
            showTimePicker()
            return false // Prevent standard keyboard
        }
        
        return true // For Name field, allow standard keyboard
    }
    
    // --- SHOW/HIDE LOGIC ---
    
    func showRepeatPicker() {
        // 1. Close any open keyboards first
        view.endEditing(true)
        
        // 2. Show the Overlay
        pickerOverlay.isHidden = false
        
        // 3. SWAP THE VIEWS
        repeatPicker.isHidden = false // Show this one
        timePicker.isHidden = true    // Hide the other one
    }
    
    func showTimePicker() {
        // 1. Close any open keyboards first
        view.endEditing(true)
        
        // 2. Show the Overlay
        pickerOverlay.isHidden = false
        
        // 3. SWAP THE VIEWS
        repeatPicker.isHidden = true  // Hide this one
        timePicker.isHidden = false   // Show the other one
    }
    
    @objc func dismissPopup() {
        // --- FIX: UPDATE TEXT FIELDS ON DISMISS ---
                // This ensures the value is set even if the user didn't scroll
                
                if !repeatPicker.isHidden {
                    // Get current selected row from Repeat Picker
                    let selectedRow = repeatPicker.selectedRow(inComponent: 0)
                    repeatTextField.text = weekDays[selectedRow]
                }
                else if !timePicker.isHidden {
                    // Get current date from Time Picker
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    timeTextField.text = formatter.string(from: timePicker.date)
                }
                
                pickerOverlay.isHidden = true
    }

    // --- PICKER DELEGATE (Repeat) ---
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { weekDays.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { weekDays[row] }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repeatTextField.text = weekDays[row]
    }
    
    // --- ACTIONS ---
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        let time = timeTextField.text ?? "10:00 AM"
        let repeatText = repeatTextField.text ?? "Every Mon"
        
        let newPlanItem = PlanItem(id: UUID().uuidString, title: name, subtitle: repeatText, time: time, isCompleted: false)
        delegate?.didAddExercise(newPlanItem)
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension AddExerciseViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a description"
            textView.textColor = UIColor.lightGray
        }
    }
}
/*
import UIKit

// Protocol for sending data back
protocol AddExerciseDelegate: AnyObject {
    func didAddExercise(_ exercise: PlanItem)
}

class AddExerciseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // --- OUTLETS ---
    @IBOutlet weak var CloseButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: AddExerciseDelegate?
    
    // --- PICKERS ---
    let repeatPicker = UIPickerView()
    let timePicker = UIDatePicker()
    let weekDays = ["Every Mon", "Every Tue", "Every Wed", "Every Thu", "Every Fri", "Every Sat", "Every Sun", "Every Day"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupPickers()
        
        // --- NEW: Add Chevrons ---
        addChevron(to: repeatTextField)
        addChevron(to: timeTextField)
        
        // Ensure Name field delegate is set
        nameTextField.delegate = self
    }
    
    func setupUI() {
        // Round Save Button
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.backgroundColor = UIColor(red: 0.85, green: 0.4, blue: 0.5, alpha: 1.0)
        
        // Setup Description Box
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.backgroundColor = UIColor.systemGray6
        descriptionTextView.text = "Add a description"
        descriptionTextView.textColor = .lightGray
        descriptionTextView.delegate = self // Delegate is handled in extension below
        
        // Padding for Description
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
        
        // --- NEW: Add Toolbar to Description Text View ---
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        descriptionTextView.inputAccessoryView = toolbar
        
    }
    
    // --- HELPER TO ADD CHEVRON ICON ---
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
    
    func setupPickers() {
        // Repeat Picker
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
        repeatTextField.inputView = repeatPicker
        addToolbar(textField: repeatTextField)
        
        // Time Picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timeTextField.inputView = timePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(timeDonePressed))
        toolbar.setItems([doneBtn], animated: true)
        timeTextField.inputAccessoryView = toolbar
    }
    
    func addToolbar(textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneBtn], animated: true)
        textField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() { view.endEditing(true) }
    
    @objc func timeDonePressed() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeTextField.text = formatter.string(from: timePicker.date)
        view.endEditing(true)
    }
    
    // --- PICKER DELEGATE ---
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return weekDays.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return weekDays[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { repeatTextField.text = weekDays[row] }
    
    // --- ACTIONS ---
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let time = timeTextField.text?.isEmpty == false ? timeTextField.text! : "5 min"
        let subtitle = repeatTextField.text?.isEmpty == false ? repeatTextField.text! : "Custom Routine"
        
        let newPlanItem = PlanItem(
            id: UUID().uuidString,
            title: name,
            subtitle: subtitle,
            time: time,
            isCompleted: false
        )
        
        delegate?.didAddExercise(newPlanItem)
        self.dismiss(animated: true, completion: nil)
    }
    
    // UITextField Delegate to handle Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddExerciseViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            self.view.endEditing(true) // Forces keyboard to close
        }
}

*/
