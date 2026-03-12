
import UIKit

final class SymptomSelectionCell: UICollectionViewCell {

    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var mildLabel: UILabel!
    @IBOutlet weak var severeLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!

    var onCheckboxTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?
    var onSliderChanged: ((Int) -> Void)?
    var onNoteChanged: ((String) -> Void)?

    private var isSymptomSelected: Bool = false
    private let placeholderText = "Add notes (optional)"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
        severitySlider.value = 0
        noteTextView.text = ""
        setPlaceholder()
    }

    func configure(with symptom: Symptom, isSelected: Bool, severity: Int, note: String = "") {
        symptomNameLabel.text = symptom.name
        severitySlider.value = Float(severity)
        
        if note.isEmpty {
            setPlaceholder()
        } else {
            noteTextView.text = note
            noteTextView.textColor = .label
        }
        
        setSelected(isSelected)
    }

    private func setupUI() {
        severitySlider.minimumValue = 0
        severitySlider.maximumValue = 4
        severitySlider.isContinuous = true

        noteTextView.delegate = self
        noteTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setPlaceholder()

        sliderContainerView.isHidden = true
        noteTextView.isHidden = true

        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        severitySlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    private func setPlaceholder() {
        noteTextView.text = placeholderText
        noteTextView.textColor = .systemGray
    }

    private func setSelected(_ selected: Bool) {
        isSymptomSelected = selected

        let imageName = selected ? "checkmark.circle.fill" : "circle"
        checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkboxButton.tintColor = selected
            ? UIColor(named: "SymptomsPrimaryColor")
            : .systemGray

        sliderContainerView.isHidden = !selected
        noteTextView.isHidden = !selected
        
        if !selected {
            setPlaceholder()
        }
    }

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
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setPlaceholder()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text == placeholderText ? "" : textView.text ?? ""
        onNoteChanged?(text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let currentText = textView.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        let textToCount = currentText == placeholderText ? "" : prospectiveText
        return textToCount.count <= 150
    }
}
