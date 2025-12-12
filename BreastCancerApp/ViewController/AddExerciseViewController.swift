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
    
    // New property: Prefill the name field when presenting from the player
    var initialName: String?
    // New property: carry the id of the detail exercise (if presenting from player)
    var initialID: String?
    
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
        
        // Prefill name if provided
        if let name = initialName, !name.isEmpty {
            nameTextField.text = name
            nameTextField.textColor = .black
            // Optionally lock the name so user doesn't accidentally change identity — comment this line if you want editable
            // nameTextField.isEnabled = false
        }
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

        // Use initialID if present (this preserves identity), otherwise create a new UUID
        let planId = initialID ?? UUID().uuidString

        let newPlanItem = PlanItem(id: planId, title: name, subtitle: repeatText, time: time, isCompleted: false)
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
