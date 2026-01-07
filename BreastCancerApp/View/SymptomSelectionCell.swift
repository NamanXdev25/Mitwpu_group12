import UIKit

class SymptomSelectionCell: UICollectionViewCell {

    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!

    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var symptomHeaderView: UIView!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var mildLabel: UILabel!
    @IBOutlet weak var severeLabel: UILabel!

    // MARK: - State
    var isSymptomSelected: Bool = false {
        didSet {
            updateCheckboxAppearance()
            updateSliderVisibility()
        }
    }

    // MARK: - Callbacks
    var onCheckboxTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?
    var onSliderChanged: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupSlider()

        // IMPORTANT: start collapsed
        sliderContainerView.isHidden = true

        // Visuals
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
    }

    // MARK: - Configuration
    func configure(with symptom: Symptom, isSelected: Bool, severity: Int) {
        symptomNameLabel.text = symptom.name
        isSymptomSelected = isSelected
        severitySlider.value = Float(severity)

        // 🔥 Forces Auto Layout to recompute height
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    // MARK: - UI Updates
    private func updateCheckboxAppearance() {
        let imageName = isSymptomSelected ? "checkmark.circle.fill" : "circle"
        checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkboxButton.tintColor = isSymptomSelected
            ? UIColor(named: "SymptomsPrimaryColor")
            : .systemGray
    }

    private func updateSliderVisibility() {
        sliderContainerView.isHidden = !isSymptomSelected
    }

    // MARK: - Slider
    private func setupSlider() {
        severitySlider.minimumValue = 0
        severitySlider.maximumValue = 4
        severitySlider.isContinuous = true
    }

    // MARK: - Actions
    @IBAction func checkboxButtonTapped(_ sender: UIButton) {
        onCheckboxTapped?()
    }

    @IBAction func infoButtonTapped(_ sender: UIButton) {
        onInfoTapped?()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = Int(sender.value.rounded())
        sender.value = Float(value)
        onSliderChanged?(value)
    }
}
