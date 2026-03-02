import UIKit

class WaitCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var daysWaitedLabel: UILabel!
    @IBOutlet weak var daysTextField: UITextField!
    @IBOutlet weak var stepperUpButton: UIButton!
    @IBOutlet weak var stepperDownButton: UIButton!
    @IBOutlet weak var feelingsQuestionLabel: UILabel!
    @IBOutlet weak var feelingsSubtitleLabel: UILabel!
    
    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var anxiousButton: UIButton!
    @IBOutlet weak var overwhelmedButton: UIButton!
    @IBOutlet weak var scaredButton: UIButton!
    @IBOutlet weak var angryButton: UIButton!
    @IBOutlet weak var numbButton: UIButton!
    @IBOutlet weak var hopefulButton: UIButton!
    @IBOutlet weak var calmButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Colors
    // Matched exactly to XIB named colors (displayP3)
    // "light pink": r=0.988 g=0.910 b=0.937  → visible soft pink background
    // "pink":       r=0.910 g=0.416 b=0.573  → strong pink for selected + save button
    private let lightPinkColor = UIColor(
        displayP3Red: 0.9882352941,
        green:        0.9098039216,
        blue:         0.9372549020,
        alpha:        1.0
    )
    private let darkPinkColor = UIColor(
        displayP3Red: 0.9098039216,
        green:        0.4156862745,
        blue:         0.5725490196,
        alpha:        1.0
    )
    private let savedGreenColor = UIColor(red: 0.2,  green: 0.6,  blue: 0.2,  alpha: 1.0)
    private let savedGreenBg    = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
    
    // MARK: - Properties
    private var selectedFeelings: Set<String> = []
    private var currentDays: Int = 0
    private var feelingButtons: [UIButton] = []
    private var isSaved: Bool = false
    private var didSetupButtons = false
    
    var onSaveButtonTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupActions()
        setupStaticUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didSetupButtons {
            didSetupButtons = true
            setupFeelingButtons()
        }
        forceShowStaticContent()
    }
    
    // MARK: - Color Image Helper
    // setBackgroundImage always wins over XIB backgroundColor — required for UIButton
    private func colorImage(_ color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }
    
    // MARK: - Setup
    private func setupStaticUI() {
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.backgroundColor = .white
        
        statusLabel.layer.cornerRadius = 12
        statusLabel.clipsToBounds = true
        
        daysTextField.isUserInteractionEnabled = false
        daysTextField.text = ""
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = darkPinkColor
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
        saveButton.isHidden = false
        saveButton.alpha = 0.4
        saveButton.isUserInteractionEnabled = false
    }
    
    private func forceShowStaticContent() {
        daysWaitedLabel.isHidden = false
        daysWaitedLabel.alpha = 1
        
        feelingsQuestionLabel.isHidden = false
        feelingsQuestionLabel.alpha = 1
        
        feelingsSubtitleLabel.isHidden = false
        feelingsSubtitleLabel.alpha = 1
        
        stepperUpButton.isHidden = false
        stepperDownButton.isHidden = false
        daysTextField.isHidden = false
        
        for button in feelingButtons {
            button.isHidden = false
            button.alpha = 1
        }
    }
    
    private func setupFeelingButtons() {
        feelingButtons = [
            sadButton, anxiousButton, overwhelmedButton, scaredButton,
            angryButton, numbButton, hopefulButton, calmButton
        ].compactMap { $0 }
        
        for button in feelingButtons {
            button.layer.cornerRadius = 20
            button.clipsToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            button.isHidden = false
            button.alpha = 1
            button.adjustsImageWhenHighlighted = false
            applyDeselectedStyle(to: button)
        }
    }
    
    // MARK: - Feeling Button Styling
    private func applySelectedStyle(to button: UIButton) {
        button.layer.backgroundColor = darkPinkColor.cgColor
        button.setBackgroundImage(colorImage(darkPinkColor), for: .normal)
        button.setBackgroundImage(colorImage(darkPinkColor), for: .highlighted)
        button.setBackgroundImage(colorImage(darkPinkColor), for: .selected)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.textColor = .white
    }
    
    private func applyDeselectedStyle(to button: UIButton) {
        button.layer.backgroundColor = lightPinkColor.cgColor
        button.setBackgroundImage(colorImage(lightPinkColor), for: .normal)
        button.setBackgroundImage(colorImage(lightPinkColor), for: .highlighted)
        button.setBackgroundImage(colorImage(lightPinkColor), for: .selected)
        button.setTitleColor(darkPinkColor, for: .normal)
        button.setTitleColor(darkPinkColor, for: .highlighted)
        button.setTitleColor(darkPinkColor, for: .selected)
        button.titleLabel?.textColor = darkPinkColor
    }
    
    private func setupActions() {
        stepperUpButton.addTarget(self, action: #selector(stepperUpTapped), for: .touchUpInside)
        stepperDownButton.addTarget(self, action: #selector(stepperDownTapped), for: .touchUpInside)
        sadButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        anxiousButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        overwhelmedButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        scaredButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        angryButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        numbButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        hopefulButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        calmButton.addTarget(self, action: #selector(feelingButtonTapped(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func stepperUpTapped() {
        currentDays += 1
        daysTextField.text = "\(currentDays)"
        updateSaveButtonState()
    }
    
    @objc private func stepperDownTapped() {
        if currentDays > 0 {
            currentDays -= 1
            daysTextField.text = currentDays == 0 ? "" : "\(currentDays)"
            updateSaveButtonState()
        }
    }
    
    @objc private func feelingButtonTapped(_ sender: UIButton) {
        guard !isSaved else { return }
        guard let title = sender.titleLabel?.text else { return }
        let components = title.components(separatedBy: " ")
        let feeling = components.count > 1 ? components[1] : title
        
        if selectedFeelings.contains(feeling) {
            selectedFeelings.remove(feeling)
            applyDeselectedStyle(to: sender)
        } else {
            selectedFeelings.insert(feeling)
            applySelectedStyle(to: sender)
        }
        
        updateSaveButtonState()
    }
    
    @objc private func saveButtonTapped() {
        guard !isSaved else { return }
        isSaved = true
        
        saveButton.setTitle("Saved", for: .normal)
        saveButton.backgroundColor = darkPinkColor
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.alpha = 1.0
        saveButton.isUserInteractionEnabled = false
        
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = savedGreenBg
        statusLabel.textColor = savedGreenColor
        
        stepperUpButton.isUserInteractionEnabled = false
        stepperDownButton.isUserInteractionEnabled = false
        
        onSaveButtonTapped?()
    }
    
    // MARK: - Save Button State
    private func updateSaveButtonState() {
        guard !isSaved else { return }
        let shouldEnable = currentDays > 0 && !selectedFeelings.isEmpty
        saveButton.isUserInteractionEnabled = shouldEnable
        UIView.animate(withDuration: 0.2) {
            self.saveButton.alpha = shouldEnable ? 1.0 : 0.4
        }
    }
    
    // MARK: - Height Helper
    func getCellHeight() -> CGFloat {
        return 480
    }
    
    // MARK: - Configuration
    func configure(with model: WaitModel) {
        daysWaitedLabel.isHidden = false
        daysWaitedLabel.alpha = 1
        feelingsQuestionLabel.isHidden = false
        feelingsQuestionLabel.alpha = 1
        feelingsSubtitleLabel.isHidden = false
        feelingsSubtitleLabel.alpha = 1
        stepperUpButton.isHidden = false
        stepperDownButton.isHidden = false
        daysTextField.isHidden = false
        feelingButtons.forEach {
            $0.isHidden = false
            $0.alpha = 1
        }
        
        if model.status == "Completed" {
            isSaved = true
            
            statusLabel.text = "Completed"
            statusLabel.backgroundColor = savedGreenBg
            statusLabel.textColor = savedGreenColor
            
            saveButton.isHidden = false
            saveButton.setTitle("Saved", for: .normal)
            saveButton.backgroundColor = darkPinkColor
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.alpha = 1.0
            saveButton.isUserInteractionEnabled = false
            
            stepperUpButton.isUserInteractionEnabled = false
            stepperDownButton.isUserInteractionEnabled = false
            
        } else {
            isSaved = false
            
            statusLabel.text = "Not Started"
            statusLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            statusLabel.textColor = .gray
            
            saveButton.isHidden = false
            saveButton.setTitle("Save", for: .normal)
            saveButton.backgroundColor = darkPinkColor
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.isUserInteractionEnabled = false
            saveButton.alpha = 0.4
            
            stepperUpButton.isUserInteractionEnabled = true
            stepperDownButton.isUserInteractionEnabled = true
        }
        
        if let days = model.daysWaited {
            currentDays = days
            daysTextField.text = "\(days)"
        }
        
        selectedFeelings = model.selectedFeelings
        updateFeelingButtonStates()
        updateSaveButtonState()
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateFeelingButtonStates() {
        for button in feelingButtons {
            guard let title = button.titleLabel?.text else { continue }
            let components = title.components(separatedBy: " ")
            let feeling = components.count > 1 ? components[1] : title
            
            if selectedFeelings.contains(feeling) {
                applySelectedStyle(to: button)
            } else {
                applyDeselectedStyle(to: button)
            }
        }
    }
}
