import UIKit

class SymptomSelectionCell: UITableViewCell {
    
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var mildLabel: UILabel!
    @IBOutlet weak var severeLabel: UILabel!
    @IBOutlet weak var sliderContainerView: UIView!
    
    var isSymptomSelected: Bool = false {
        didSet {
            updateCheckboxAppearance()
            updateSliderVisibility()
        }
    }
    
    var onCheckboxTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?
    var onSliderChanged: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupSlider()
        updateSliderVisibility()
    }
    
    private func setupSlider() {
        severitySlider.minimumValue = 0
        severitySlider.maximumValue = 4
        severitySlider.value = 0
        severitySlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    func configure(with symptom: Symptom, isSelected: Bool, severity: Int) {
        symptomNameLabel.text = symptom.name
        self.isSymptomSelected = isSelected
        severitySlider.value = Float(severity)
    }
    
    private func updateCheckboxAppearance() {
        if isSymptomSelected {
            checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkboxButton.tintColor = .systemPink
        } else {
            checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
            checkboxButton.tintColor = .systemGray
        }
    }

    private func updateSliderVisibility() {
        sliderContainerView.isHidden = !isSymptomSelected
    }
    
    @IBAction func checkboxButtonTapped(_ sender: UIButton) {
        onCheckboxTapped?()
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        onInfoTapped?()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let roundedValue = Int(sender.value.rounded())
        sender.value = Float(roundedValue)
        onSliderChanged?(roundedValue)
    }
}
