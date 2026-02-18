import UIKit

class TreatmentPhaseView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var phaseTitleLabel: UILabel!
    @IBOutlet weak var dropdownContainerView: UIView!
    @IBOutlet weak var dropdownLabel: UILabel!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var startDateContainerView: UIView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var cycleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var supportMessageView: UIView!
    @IBOutlet weak var supportMessageLabel: UILabel!
    
    // MARK: - Properties
    private var phaseIndex: Int = 0
    private var phaseModel = TreatmentPhaseModel()
    private let pink = UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        layer.cornerRadius = 14
        
        // Dropdown styling
        dropdownContainerView.backgroundColor = .white
        dropdownContainerView.layer.borderColor = UIColor.lightGray.cgColor
        dropdownContainerView.layer.borderWidth = 1
        dropdownContainerView.layer.cornerRadius = 10
        
        // Start date styling
        startDateContainerView.backgroundColor = .white
        startDateContainerView.layer.borderColor = UIColor.lightGray.cgColor
        startDateContainerView.layer.borderWidth = 1
        startDateContainerView.layer.cornerRadius = 10
        
        // Duration text field styling
        durationTextField.layer.borderColor = UIColor.lightGray.cgColor
        durationTextField.layer.borderWidth = 1
        durationTextField.layer.cornerRadius = 10
        let durationPadding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        durationTextField.leftView = durationPadding
        durationTextField.leftViewMode = .always
        
        // Cycle text field styling
        cycleTextField.layer.borderColor = UIColor.lightGray.cgColor
        cycleTextField.layer.borderWidth = 1
        cycleTextField.layer.cornerRadius = 10
        let cyclePadding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        cycleTextField.leftView = cyclePadding
        cycleTextField.leftViewMode = .always
        
        // Save button styling
        saveButton.backgroundColor = UIColor(red: 1.0, green: 0.92, blue: 0.95, alpha: 1.0) // light pink
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 14
        saveButton.isEnabled = false
        
        // Support message styling
        supportMessageView.layer.cornerRadius = 12
        supportMessageLabel.textColor = .lightGray
    }
    
    // MARK: - IBActions
    @IBAction func dropdownTapped(_ sender: UIButton) {
        print("🔽 Dropdown tapped")
        // Show picker popup
    }
    
    @IBAction func dateTapped(_ sender: UIButton) {
        print("📅 Date tapped")
        // Show date picker
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        print("💾 Save tapped")
    }
    
    // MARK: - Configure
    func configure(index: Int) {
        phaseIndex = index
        phaseTitleLabel.text = "Phase \(index + 1)"
    }
}
