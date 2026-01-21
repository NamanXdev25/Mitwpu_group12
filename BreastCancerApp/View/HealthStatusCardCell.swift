import UIKit

final class HealthStatusCardCell: UICollectionViewCell {

    static let reuseIdentifier = "HealthStatusCardCell"

    // MARK: - Value Labels (View mode)

    @IBOutlet private weak var firstNameValueLabel: UILabel!
    @IBOutlet private weak var lastNameValueLabel: UILabel!
    @IBOutlet private weak var diagnosisDateValueLabel: UILabel!
    @IBOutlet private weak var genderValueLabel: UILabel!
    @IBOutlet private weak var ageValueLabel: UILabel!
    @IBOutlet private weak var cancerStageValueLabel: UILabel!
    @IBOutlet private weak var treatmentStateValueLabel: UILabel!
    @IBOutlet private weak var treatmentCompletionDateValueLabel: UILabel! // NEW

    // MARK: - TextFields (Edit mode)

    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var diagnosisDateTextField: UITextField!
    @IBOutlet private weak var genderTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var cancerStageTextField: UITextField!
    @IBOutlet private weak var treatmentStateTextField: UITextField!
    @IBOutlet private weak var treatmentCompletionDateTextField: UITextField! // NEW

    // MARK: - Collections

    private lazy var valueLabels: [UILabel] = [
        firstNameValueLabel,
        lastNameValueLabel,
        diagnosisDateValueLabel,
        genderValueLabel,
        ageValueLabel,
        cancerStageValueLabel,
        treatmentStateValueLabel,
        treatmentCompletionDateValueLabel
    ]

    private lazy var editableFields: [UITextField] = [
        firstNameTextField,
        lastNameTextField,
        diagnosisDateTextField,
        genderTextField,
        ageTextField,
        cancerStageTextField,
        treatmentStateTextField,
        treatmentCompletionDateTextField
    ]

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        editableFields.forEach {
            $0.borderStyle = .none
            $0.backgroundColor = .clear
            $0.textColor = UIColor(named: "pink")
            $0.textAlignment = .right
        }

       
        treatmentCompletionDateTextField.placeholder = "—"

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
        treatmentState: String,
        treatmentCompletionDate: String
    ) {
        let values = [
            firstName,
            lastName,
            diagnosisDate,
            gender,
            age,
            cancerStage,
            treatmentState,
            treatmentCompletionDate
        ]

        // View mode: show "—" if empty
        zip(valueLabels, values).forEach { label, value in
            label.text = value.isEmpty ? "—" : value
        }

        // Edit mode: EMPTY field, never "—"
        zip(editableFields, values).forEach { field, value in
            field.text = value.isEmpty ? "" : value
        }
    }

    // MARK: - Editing

    func setEditing(_ editing: Bool) {
        valueLabels.forEach { $0.isHidden = editing }
        editableFields.forEach { $0.isHidden = !editing }
    }

    func commitEdits() {
        zip(editableFields, valueLabels).forEach { field, label in
            label.text = field.text?.isEmpty == false ? field.text : "—"
        }
    }

    func revertEdits() {
        zip(valueLabels, editableFields).forEach { label, field in
            field.text = label.text == "—" ? "" : label.text
        }
    }

    // MARK: - Data Accessors

    var currentName: (first: String, last: String)? {
        guard
            let first = firstNameTextField.text,
            let last = lastNameTextField.text
        else { return nil }

        return (first, last)
    }

    var currentMedicalInfo: (
        diagnosisDate: String,
        gender: String,
        age: String,
        cancerStage: String,
        treatmentState: String,
        treatmentCompletionDate: String
    ) {
        (
            diagnosisDate: diagnosisDateTextField.text ?? "",
            gender: genderTextField.text ?? "",
            age: ageTextField.text ?? "",
            cancerStage: cancerStageTextField.text ?? "",
            treatmentState: treatmentStateTextField.text ?? "",
            treatmentCompletionDate: treatmentCompletionDateTextField.text ?? ""
        )
    }
}
