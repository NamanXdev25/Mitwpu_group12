//
//  SymptomSelectionCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/01/26.
//

import UIKit

final class SymptomSelectionCell: UICollectionViewCell {

    // IBOutlets
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var mildLabel: UILabel!
    @IBOutlet weak var severeLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!

    // Callbacks
    var onCheckboxTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?
    var onSliderChanged: ((Int) -> Void)?
    var onNoteChanged: ((String) -> Void)?

    private var isSymptomSelected: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
        severitySlider.value = 0
        noteTextView.text = ""
    }

    func configure(with symptom: Symptom, isSelected: Bool, severity: Int, note: String = "") {
        symptomNameLabel.text = symptom.name
        severitySlider.value = Float(severity)
        //noteTextView.text = note
        setSelected(isSelected)
    }

    // UI setup
    private func setupUI() {
        // slider config
        severitySlider.minimumValue = 0
        severitySlider.maximumValue = 4
        severitySlider.isContinuous = true

        // note text view config
        noteTextView.delegate = self
        noteTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // initial collapsed state
        sliderContainerView.isHidden = true
        noteTextView.isHidden = true

        // Button actions
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        severitySlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }

    // selection
    private func setSelected(_ selected: Bool) {
        isSymptomSelected = selected

        let imageName = selected ? "checkmark.circle.fill" : "circle"
        checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkboxButton.tintColor = selected
            ? UIColor(named: "SymptomsPrimaryColor")
            : .systemGray

        sliderContainerView.isHidden = !selected
        noteTextView.isHidden = !selected
    }

    // actions
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

// MARK: - UITextViewDelegate
extension SymptomSelectionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onNoteChanged?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Dismiss keyboard on return
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
