import UIKit

class PostTreatmentCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var painButton: UIButton!
    @IBOutlet weak var numbnessButton: UIButton!
    @IBOutlet weak var swellingButton: UIButton!
    @IBOutlet weak var stiffnessButton: UIButton!
    @IBOutlet weak var fatigueButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var supportMessageView: UIView!
    @IBOutlet weak var supportMessageLabel: UILabel!
    @IBOutlet weak var recommendationsContainerView: UIView!
    @IBOutlet weak var recommendationCardView: UIView!
    @IBOutlet weak var recommendationTitleLabel: UILabel!
    @IBOutlet weak var recommendationSubtitleLabel: UILabel!
    
    // MARK: - Colors
    private let pink            = UIColor(red: 0.91, green: 0.39, blue: 0.54, alpha: 1.0)
    private let darkPink        = UIColor(red: 0.75, green: 0.15, blue: 0.35, alpha: 1.0)
    private let lightPink       = UIColor(red: 1.0,  green: 0.92, blue: 0.95, alpha: 1.0)
    private let savedGreenColor = UIColor(red: 0.2,  green: 0.6,  blue: 0.2,  alpha: 1.0)
    private let savedGreenBg    = UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0)
    
    // MARK: - State
    private var selectedSymptoms: Set<String> = []
    private var selectedDate: Date?
    private var isSaved = false
    private var symptomTitles: [UIButton: String] = [:]
    
    var onDateTapped: (() -> Void)?
    var onCellHeightChanged: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    // MARK: - Setup
    private func setupCell() {
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .white
        
        statusLabel.backgroundColor = UIColor(white: 0.94, alpha: 1)
        statusLabel.layer.cornerRadius = 10
        statusLabel.layer.masksToBounds = true
        
        dateContainerView.layer.borderColor = UIColor.lightGray.cgColor
        dateContainerView.layer.borderWidth = 1
        dateContainerView.layer.cornerRadius = 10
        
        symptomTitles = [
            painButton:      "Pain",
            numbnessButton:  "Numbness",
            swellingButton:  "Swelling",
            stiffnessButton: "Stiffness",
            fatigueButton:   "Fatigue"
        ]
        
        for (btn, title) in symptomTitles {
            btn.layer.cornerRadius = 20
            btn.clipsToBounds = true
            btn.isUserInteractionEnabled = true
            btn.isSelected = false

            var config = btn.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = lightPink
            config.baseForegroundColor = pink
            config.cornerStyle = .capsule
            btn.configuration = config

            btn.removeTarget(nil, action: nil, for: .allEvents)
            btn.addTarget(self, action: #selector(symptomTapped(_:)), for: .touchUpInside)
        }
        
        saveButton.adjustsImageWhenDisabled = false
        saveButton.adjustsImageWhenHighlighted = false
        saveButton.layer.cornerRadius = 14
        saveButton.clipsToBounds = true
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.backgroundColor = pink
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.isEnabled = true
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.4
        
        supportMessageView.layer.cornerRadius = 12
        supportMessageView.isHidden = false
        supportMessageView.alpha = 0.4
        
        recommendationsContainerView.isHidden = true
    }
    
    private func symptomButtons() -> [UIButton] {
        [painButton, numbnessButton, swellingButton,
         stiffnessButton, fatigueButton].compactMap { $0 }
    }
    
    // MARK: - Symptom Tap Handler
    @objc private func symptomTapped(_ sender: UIButton) {
        guard !isSaved else { return }
        let title = symptomTitles[sender] ?? ""
        guard !title.isEmpty else { return }
        
        if selectedSymptoms.contains(title) {
            selectedSymptoms.remove(title)
            sender.isSelected = false
            var config = sender.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = lightPink
            config.baseForegroundColor = pink
            sender.configuration = config
        } else {
            selectedSymptoms.insert(title)
            sender.isSelected = true
            var config = sender.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = pink
            config.baseForegroundColor = .white
            sender.configuration = config
        }
        
        updateState()
    }

    // MARK: - IBActions
    @IBAction func dateTapped(_ sender: UIButton) {
        guard !isSaved else { return }
        showInternalDatePicker()
    }
    
    @IBAction func painTapped(_ sender: UIButton)       {}
    @IBAction func numbnessTapped(_ sender: UIButton)   {}
    @IBAction func swellingTapped(_ sender: UIButton)   {}
    @IBAction func stiffnessTapped(_ sender: UIButton)  {}
    @IBAction func fatigueTapped(_ sender: UIButton)    {}
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !isSaved, selectedDate != nil, !selectedSymptoms.isEmpty else { return }
        isSaved = true
        
        saveButton.setTitle("✓  Recovery Details Saved", for: .normal)
        saveButton.backgroundColor = savedGreenColor
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 1.0
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = savedGreenBg
        statusLabel.textColor = savedGreenColor
        
        supportMessageView.isHidden = true
        recommendationsContainerView.isHidden = true
        
        dateButton.isUserInteractionEnabled = false
        symptomButtons().forEach { $0.isUserInteractionEnabled = false }
        
        onCellHeightChanged?()
    }
    
    // MARK: - State Update
    private func updateState() {
        guard !isSaved else { return }
        let allFilled = selectedDate != nil && !selectedSymptoms.isEmpty
        
        UIView.animate(withDuration: 0.25) {
            self.saveButton.alpha         = allFilled ? 1.0 : 0.4
            self.supportMessageView.alpha = allFilled ? 1.0 : 0.4
        }
        saveButton.isUserInteractionEnabled = allFilled
    }
    
    // MARK: - Date Picker
    private func showInternalDatePicker() {
        guard let window = self.window else { return }
        
        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimView.tag = 9001
        dimView.alpha = 0
        window.addSubview(dimView)
        
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor   = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.15
        container.layer.shadowRadius  = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        dimView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 340),
            container.heightAnchor.constraint(equalToConstant: 420)
        ])
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = pink
        datePicker.date = selectedDate ?? Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(datePicker)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        doneButton.setTitleColor(pink, for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 4),
            doneButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            doneButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        datePicker.addTarget(self, action: #selector(pickerChanged(_:)), for: .valueChanged)
        
        doneButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.commitDate(datePicker.date)
            self.dismissPicker()
        }, for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        tap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.22) { dimView.alpha = 1 }
    }
    
    @objc private func pickerChanged(_ picker: UIDatePicker) {
        commitDate(picker.date)
    }
    
    private func commitDate(_ date: Date) {
        selectedDate = date
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        dateLabel.text = f.string(from: date)
        dateLabel.textColor = .black
        updateState()
    }
    
    @objc private func dismissPicker() {
        guard let window = self.window,
              let dim = window.viewWithTag(9001) else { return }
        UIView.animate(withDuration: 0.2, animations: { dim.alpha = 0 }) { _ in
            dim.removeFromSuperview()
        }
    }
    
    // MARK: - Public
    func updateSelectedDate(_ date: Date) { commitDate(date) }
    
    // MARK: - Configure
    func configure() {
        isSaved = false
        selectedSymptoms.removeAll()
        selectedDate = nil
        
        dateLabel.text = "dd/mm/yyyy"
        dateLabel.textColor = .lightGray
        
        saveButton.setTitle("Save Recovery Details", for: .normal)
        saveButton.backgroundColor = pink
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.isUserInteractionEnabled = false
        saveButton.isEnabled = true
        saveButton.alpha = 0.4
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        statusLabel.text = "Not Started"
        statusLabel.backgroundColor = UIColor(white: 0.94, alpha: 1)
        statusLabel.textColor = UIColor(white: 0.4, alpha: 1)
        
        supportMessageView.isHidden = false
        supportMessageView.alpha = 0.4
        recommendationsContainerView.isHidden = true
        
        dateButton.isUserInteractionEnabled = true
        
        for (btn, title) in symptomTitles {
            btn.setTitle(title, for: .normal)
            btn.isSelected = false
            var config = btn.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = lightPink
            config.baseForegroundColor = pink
            btn.configuration = config
            btn.isUserInteractionEnabled = true
        }
    }
    
    func getCellHeight() -> CGFloat { return 420 }
}
