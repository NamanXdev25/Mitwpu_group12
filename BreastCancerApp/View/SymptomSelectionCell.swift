//
//  SymptomSelectionCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/01/26.
//

import UIKit

final class SymptomSelectionCell: UICollectionViewCell {

    // MARK: - Outlets (Top Row)
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!

    // MARK: - Slider Section
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var mildLabel: UILabel!
    @IBOutlet weak var severeLabel: UILabel!

    // MARK: - Callbacks
    var onCheckboxTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?
    var onSliderChanged: ((Int) -> Void)?

    // MARK: - State
    private var isSymptomSelected: Bool = false

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset state for reuse
        setSelected(false)
        severitySlider.value = 0
    }

    // MARK: - Public Configure
    func configure(with symptom: Symptom, isSelected: Bool, severity: Int) {
        symptomNameLabel.text = symptom.name
        severitySlider.value = Float(severity)
        setSelected(isSelected)
    }

    // MARK: - Private UI Setup
    private func setupUI() {
        // Slider config
        severitySlider.minimumValue = 0
        severitySlider.maximumValue = 4
        severitySlider.isContinuous = true

        // Initial collapsed state
        sliderContainerView.isHidden = true

        // Button actions
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        severitySlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        // Cell appearance
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .white
    }

    // MARK: - State Handling
    private func setSelected(_ selected: Bool) {
        isSymptomSelected = selected

        // Checkbox UI
        let imageName = selected ? "checkmark.circle.fill" : "circle"
        checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkboxButton.tintColor = selected
            ? UIColor(named: "SymptomsPrimaryColor")
            : .systemGray

        // Slider visibility
        sliderContainerView.isHidden = !selected
    }

    // MARK: - Actions
    @objc private func checkboxTapped() {
        onCheckboxTapped?()
    }

    @objc private func infoTapped() {
        onInfoTapped?()
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let rounded = Int(sender.value.rounded())
        sender.value = Float(rounded)
        onSliderChanged?(rounded)
    }
}
