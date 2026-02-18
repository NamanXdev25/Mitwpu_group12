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
    @IBOutlet weak var successMessageView: UIView!
    @IBOutlet weak var successMessageLabel: UILabel!
    
    @IBOutlet weak var supportTitleLabel: UILabel!
    @IBOutlet weak var suggestionsContainerView: UIView!
    @IBOutlet weak var suggestionTitleLabel: UILabel!
    @IBOutlet weak var suggestionDescriptionLabel: UILabel!
    @IBOutlet weak var suggestion2TitleLabel: UILabel!
    @IBOutlet weak var suggestion2DescriptionLabel: UILabel!
    @IBOutlet weak var suggestion3TitleLabel: UILabel!
    @IBOutlet weak var suggestion3DescriptionLabel: UILabel!
    
    // MARK: - Properties
    private var selectedFeelings: Set<String> = []
    private var currentDays: Int = 0
    private var feelingButtons: [UIButton] = []
    
    private let lightPinkColor = UIColor(red: 0.99, green: 0.96, blue: 0.97, alpha: 1.0)
    private let darkPinkColor = UIColor(red: 0.93, green: 0.45, blue: 0.64, alpha: 1.0)
    
    var onSaveButtonTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupFeelingButtons()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
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
        
        feelingsQuestionLabel.isHidden = false
        feelingsSubtitleLabel.isHidden = false
        
        saveButton.isHidden = true
        saveButton.backgroundColor = darkPinkColor
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
        
        successMessageView.isHidden = true
        successMessageView.backgroundColor = .clear
        successMessageLabel.isHidden = false
        
        supportTitleLabel.isHidden = true
        suggestionsContainerView.isHidden = true
    }
    
    private func setupFeelingButtons() {
        feelingButtons = [
            sadButton, anxiousButton, overwhelmedButton, scaredButton,
            angryButton, numbButton, hopefulButton, calmButton
        ]
        
        for button in feelingButtons {
            button.backgroundColor = lightPinkColor
            button.setTitleColor(darkPinkColor, for: .normal)
            button.layer.cornerRadius = 20
            button.clipsToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        }
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
        checkIfShouldShowSaveButton()
    }
    
    @objc private func stepperDownTapped() {
        if currentDays > 0 {
            currentDays -= 1
            daysTextField.text = currentDays == 0 ? "" : "\(currentDays)"
            checkIfShouldShowSaveButton()
        }
    }
    
    @objc private func feelingButtonTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        let components = title.components(separatedBy: " ")
        let feeling = components.count > 1 ? components[1] : title
        
        if selectedFeelings.contains(feeling) {
            selectedFeelings.remove(feeling)
            sender.backgroundColor = lightPinkColor
            sender.setTitleColor(darkPinkColor, for: .normal)
        } else {
            selectedFeelings.insert(feeling)
            sender.backgroundColor = darkPinkColor
            sender.setTitleColor(.white, for: .normal)
        }
        
        checkIfShouldShowSaveButton()
    }
    
    @objc private func saveButtonTapped() {
        saveButton.isHidden = true
        successMessageView.isHidden = false
        successMessageLabel.isHidden = false
        
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
        statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        
        supportTitleLabel.isHidden = true
        suggestionsContainerView.isHidden = false
        
        updateSuggestions()
        onSaveButtonTapped?()
        onCellHeightChanged?()
    }
    
    private func checkIfShouldShowSaveButton() {
        let shouldShow = currentDays > 0 && !selectedFeelings.isEmpty
        if shouldShow != !saveButton.isHidden {
            saveButton.isHidden = !shouldShow
            onCellHeightChanged?()
        }
    }
    
    private func updateSuggestions() {
        let allSuggestions = [
            Suggestion(title: "Managing Anxiety",
                      description: "Breathing exercises and grounding techniques",
                      relatedFeelings: ["Anxious", "Overwhelmed", "Scared"]),
            Suggestion(title: "Emotional Support",
                      description: "Gentle ways to process difficult emotions",
                      relatedFeelings: ["Sad", "Numb"]),
            Suggestion(title: "Managing Anger",
                      description: "Physical activity and mindfulness practices",
                      relatedFeelings: ["Angry"]),
            Suggestion(title: "Self-Care Practices",
                      description: "Nurturing activities for emotional wellbeing",
                      relatedFeelings: ["Hopeful", "Calm"]),
            Suggestion(title: "Building Resilience",
                      description: "Strategies to strengthen emotional capacity",
                      relatedFeelings: ["Sad", "Scared", "Overwhelmed"])
        ]
        
        var relevantSuggestions: [Suggestion] = []
        for suggestion in allSuggestions {
            for feeling in selectedFeelings {
                if suggestion.relatedFeelings.contains(feeling) {
                    if !relevantSuggestions.contains(where: { $0.title == suggestion.title }) {
                        relevantSuggestions.append(suggestion)
                    }
                    break
                }
            }
        }
        
        if relevantSuggestions.count < 3 {
            for suggestion in allSuggestions {
                if !relevantSuggestions.contains(where: { $0.title == suggestion.title }) {
                    relevantSuggestions.append(suggestion)
                }
                if relevantSuggestions.count >= 3 { break }
            }
        }
        
        if relevantSuggestions.count > 0 {
            suggestionTitleLabel.text = relevantSuggestions[0].title
            suggestionDescriptionLabel.text = relevantSuggestions[0].description
        }
        if relevantSuggestions.count > 1 {
            suggestion2TitleLabel.text = relevantSuggestions[1].title
            suggestion2DescriptionLabel.text = relevantSuggestions[1].description
        }
        if relevantSuggestions.count > 2 {
            suggestion3TitleLabel.text = relevantSuggestions[2].title
            suggestion3DescriptionLabel.text = relevantSuggestions[2].description
        }
    }
    
    // MARK: - Height Helper
    func getCellHeight() -> CGFloat {
        var height: CGFloat = 540

        if !saveButton.isHidden {
            height += 70
        }
        if !successMessageView.isHidden {
            height += 60
        }
        if !suggestionsContainerView.isHidden {
            height += 330
        }

        return height
    }
    
    // MARK: - Configuration
    func configure(with model: WaitModel) {
        statusLabel.text = model.status
        feelingsQuestionLabel.isHidden = false
        feelingsSubtitleLabel.isHidden = false
        
        if model.status == "Completed" {
            statusLabel.backgroundColor = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
            successMessageView.isHidden = false
            successMessageLabel.isHidden = false
            supportTitleLabel.isHidden = true
            suggestionsContainerView.isHidden = false
            saveButton.isHidden = true
        } else {
            statusLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            statusLabel.textColor = .gray
            successMessageView.isHidden = true
            supportTitleLabel.isHidden = true
            suggestionsContainerView.isHidden = true
            saveButton.isHidden = true
        }
        
        if let days = model.daysWaited {
            currentDays = days
            daysTextField.text = "\(days)"
        }
        
        selectedFeelings = model.selectedFeelings
        updateFeelingButtonStates()
    }
    
    private func updateFeelingButtonStates() {
        for button in feelingButtons {
            guard let title = button.titleLabel?.text else { continue }
            let components = title.components(separatedBy: " ")
            let feeling = components.count > 1 ? components[1] : title
            
            if selectedFeelings.contains(feeling) {
                button.backgroundColor = darkPinkColor
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = lightPinkColor
                button.setTitleColor(darkPinkColor, for: .normal)
            }
        }
    }
}
