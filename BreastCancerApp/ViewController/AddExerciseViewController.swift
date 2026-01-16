import UIKit

protocol AddExerciseDelegate: AnyObject {
    func didAddExercise(_ exercise: PlanItem)
}

class AddExerciseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // --- FORM OUTLETS ---
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    // NEW: Chevron Image Views
    @IBOutlet weak var repeatChevronImageView: UIImageView!
    @IBOutlet weak var timeChevronImageView: UIImageView!
    
    // --- POPUP OUTLETS ---
    @IBOutlet weak var pickerOverlay: UIView!
    @IBOutlet weak var pickerCard: UIView!
    @IBOutlet weak var repeatPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    weak var delegate: AddExerciseDelegate?
    
    var initialName: String?
    var initialID: String?
    
    var isNameEditable: Bool = true
    
    var initialSubtitle: String?
    var initialTime: String?
    var initialDescription: String?
    
    let weekDays = ["Every Mon", "Every Tue", "Every Wed", "Every Thu", "Every Fri", "Every Sat", "Every Sun", "Every Day"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        nameTextField.delegate = self
        repeatTextField.delegate = self
        timeTextField.delegate = self
        
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "en_US")
        
        setupChevronTapGestures()
        
        pickerOverlay.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        pickerOverlay.addGestureRecognizer(tapGesture)
        
        if let name = initialName, !name.isEmpty {
            nameTextField.text = name
            nameTextField.textColor = .black
        }
        
        if !isNameEditable {
            nameTextField.isUserInteractionEnabled = false
            nameTextField.textColor = .darkGray
            nameTextField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        }
        
        if let sub = initialSubtitle, !sub.isEmpty {
            repeatTextField.text = sub
        }
        
        if let t = initialTime, !t.isEmpty {
            timeTextField.text = t
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            if let date = formatter.date(from: t) {
                timePicker.date = date
            }
        }
        
        if let desc = initialDescription, !desc.isEmpty {
            descriptionTextView.text = desc
            descriptionTextView.textColor = .black
        }
    }
    
    func setupUI() {
        pickerCard.layer.cornerRadius = 16
        pickerCard.layer.shadowColor = UIColor.black.cgColor
        pickerCard.layer.shadowOpacity = 0.2
        pickerCard.layer.shadowRadius = 10
        
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.backgroundColor = UIColor.systemGray6
        descriptionTextView.text = "Add a description"
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.textColor = .lightGray
        descriptionTextView.delegate = self
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
    }

    func setupChevronTapGestures() {
        repeatChevronImageView.isUserInteractionEnabled = true
        timeChevronImageView.isUserInteractionEnabled = true
        
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField && !isNameEditable {
            return false
        }
        
        if textField == repeatTextField {
            showRepeatPicker()
            return false
        }
        else if textField == timeTextField {
            showTimePicker()
            return false
        }
        
        return true
    }
    
    
    func showRepeatPicker() {
        view.endEditing(true)
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
            repeatTextField.text = weekDays[selectedRow]
        }
        else if !timePicker.isHidden {
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
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            showAlert(message: "Please enter a name for the exercise.")
            return
        }
        
        guard let repeatText = repeatTextField.text, !repeatText.isEmpty else {
            showAlert(message: "Please select how often to repeat the exercise.")
            return
        }
        
        guard let time = timeTextField.text, !time.isEmpty else {
            showAlert(message: "Please select a time for the exercise.")
            return
        }

        let planId = initialID ?? UUID().uuidString
        
        var description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if description == "Add a description" {
            description = ""
        }

        let newPlanItem = PlanItem(id: planId, title: name, subtitle: repeatText, time: time, isCompleted: false, description: description)
        delegate?.didAddExercise(newPlanItem)
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Required Field", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
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
