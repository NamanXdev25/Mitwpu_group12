import UIKit

protocol AddExerciseDelegate: AnyObject {
    func didAddExercise(_ exercise: PlanItem)
}

class AddExerciseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // --- FORM OUTLETS ---
    @IBOutlet weak var closeBarButton: UIBarButtonItem! // Changed to UIBarButtonItem
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem! // Changed to UIBarButtonItem
    
    // NEW: Chevron Image Views (no longer added programmatically)
    @IBOutlet weak var repeatChevronImageView: UIImageView!
    @IBOutlet weak var timeChevronImageView: UIImageView!
    
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
    
    // --- NEW: Edit Mode properties ---
    var initialSubtitle: String? // For "Repeat" (e.g., "Every Mon")
    var initialTime: String?     // For "Time" (e.g., "10:00 AM")
    var initialDescription: String? // For Description
    
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
        
        // NEW: Setup tap gestures for chevron images
        setupChevronTapGestures()
        
        // 2. Setup Overlay (Start with everything HIDDEN)
        pickerOverlay.isHidden = true
        
        // 3. Add Tap Gesture to background (to close popup)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        pickerOverlay.addGestureRecognizer(tapGesture)
        
        // --- PREFILL DATA (Edit Mode) ---
        if let name = initialName, !name.isEmpty {
            nameTextField.text = name
            nameTextField.textColor = .black
        }
        
        if let sub = initialSubtitle, !sub.isEmpty {
            repeatTextField.text = sub
        }
        
        if let t = initialTime, !t.isEmpty {
            timeTextField.text = t
            // Try to sync picker to current time string
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a" // Match format used in saveTapped
            if let date = formatter.date(from: t) {
                timePicker.date = date
            }
        }
        
        // --- NEW: Prefill Description ---
        if let desc = initialDescription, !desc.isEmpty {
            descriptionTextView.text = desc
            descriptionTextView.textColor = .black
        }
    }
    
    func setupUI() {
        // Removed saveButton styling since it's now a UIBarButtonItem
        
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

    // NEW: Setup tap gestures for the chevron image views
    func setupChevronTapGestures() {
        // Make image views tappable
        repeatChevronImageView.isUserInteractionEnabled = true
        timeChevronImageView.isUserInteractionEnabled = true
        
        // Add tap gestures
        let repeatTap = UITapGestureRecognizer(target: self, action: #selector(repeatChevronTapped))
        repeatChevronImageView.addGestureRecognizer(repeatTap)
        
        let timeTap = UITapGestureRecognizer(target: self, action: #selector(timeChevronTapped))
        timeChevronImageView.addGestureRecognizer(timeTap)
    }
    
    @objc func repeatChevronTapped() {
        showRepeatPicker()
    }
    
    @objc func timeChevronTapped() {
        showTimePicker()
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
//    @IBAction func closeTapped(_ sender: UIBarButtonItem) { // Changed parameter type
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    @IBAction func saveTapped(_ sender: UIBarButtonItem) { // Changed parameter type
//        guard let name = nameTextField.text, !name.isEmpty else { return }
//        let time = timeTextField.text ?? "10:00 AM"
//        let repeatText = repeatTextField.text ?? "Every Mon"
//
//        // Use initialID if present (this preserves identity), otherwise create a new UUID
//        let planId = initialID ?? UUID().uuidString
//        
//        // --- NEW: Capture Description ---
//        var description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
//        if description == "Add a description" {
//            description = ""
//        }
//
//        let newPlanItem = PlanItem(id: planId, title: name, subtitle: repeatText, time: time, isCompleted: false, description: description)
//        delegate?.didAddExercise(newPlanItem)
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) { // Changed parameter type
            self.dismiss(animated: true, completion: nil)
       }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) { // Changed parameter type
          guard let name = nameTextField.text, !name.isEmpty else { return }
          let time = timeTextField.text ?? "10:00 AM"
          let repeatText = repeatTextField.text ?? "Every Mon"
  
          // Use initialID if present (this preserves identity), otherwise create a new UUID
          let planId = initialID ?? UUID().uuidString
  
          // --- NEW: Capture Description ---
          var description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
         if description == "Add a description" {
              description = ""
            }
  
          let newPlanItem = PlanItem(id: planId, title: name, subtitle: repeatText, time: time, isCompleted: false, description: description)
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
