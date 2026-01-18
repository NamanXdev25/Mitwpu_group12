import UIKit

final class HealthStatusCardCell: UICollectionViewCell {

    // MARK: - Reuse
    static let reuseIdentifier = "HealthStatusCardCell"

    // MARK: - Value Labels (View Mode)
    @IBOutlet private weak var firstNameValueLabel: UILabel!
    @IBOutlet private weak var lastNameValueLabel: UILabel!
    @IBOutlet private weak var diagnosisDateValueLabel: UILabel!
    @IBOutlet private weak var genderValueLabel: UILabel!
    @IBOutlet private weak var ageValueLabel: UILabel!
    @IBOutlet private weak var cancerStageValueLabel: UILabel!
    @IBOutlet private weak var treatmentStateValueLabel: UILabel!

    // MARK: - Editable TextFields (Edit Mode)
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var diagnosisDateTextField: UITextField!
    @IBOutlet private weak var genderTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var cancerStageTextField: UITextField!
    @IBOutlet private weak var treatmentStateTextField: UITextField!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTextFields()
        setEditing(false)
    }

    // MARK: - Configuration
    func configure(
        firstName: String,
        lastName: String,
        diagnosisDate: String,
        gender: String,
        age: String,
        cancerStage: String,
        treatmentState: String
    ) {
        firstNameValueLabel.text = firstName
        lastNameValueLabel.text = lastName
        diagnosisDateValueLabel.text = diagnosisDate
        genderValueLabel.text = gender
        ageValueLabel.text = age
        cancerStageValueLabel.text = cancerStage
        treatmentStateValueLabel.text = treatmentState

        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        diagnosisDateTextField.text = diagnosisDate
        genderTextField.text = gender
        ageTextField.text = age
        cancerStageTextField.text = cancerStage
        treatmentStateTextField.text = treatmentState
    }

    // MARK: - Editing
    func setEditing(_ editing: Bool) {
        valueLabels.forEach { $0.isHidden = editing }
        editableFields.forEach { $0.isHidden = !editing }
    }

    func commitEdits() {
        zip(editableFields, valueLabels).forEach { field, label in
            label.text = field.text
        }
    }

    func revertEdits() {
        zip(valueLabels, editableFields).forEach { label, field in
            field.text = label.text
        }
    }

    // MARK: - Exposed State
    var currentName: (first: String, last: String)? {
        guard
            let first = firstNameTextField.text,
            let last = lastNameTextField.text
        else {
            return nil
        }
        return (first, last)
    }

    // MARK: - Private Helpers
    private var valueLabels: [UILabel] {
        [
            firstNameValueLabel,
            lastNameValueLabel,
            diagnosisDateValueLabel,
            genderValueLabel,
            ageValueLabel,
            cancerStageValueLabel,
            treatmentStateValueLabel
        ]
    }

    private var editableFields: [UITextField] {
        [
            firstNameTextField,
            lastNameTextField,
            diagnosisDateTextField,
            genderTextField,
            ageTextField,
            cancerStageTextField,
            treatmentStateTextField
        ]
    }

    private func configureTextFields() {
        editableFields.forEach {
            $0.borderStyle = .none
            $0.backgroundColor = .clear
            $0.textColor = .systemBlue
            $0.textAlignment = .right
        }
    }
}
