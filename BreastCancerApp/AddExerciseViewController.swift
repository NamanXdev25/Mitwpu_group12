//
//  AddExerciseViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 29/11/25.
//

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
