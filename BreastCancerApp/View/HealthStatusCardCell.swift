import UIKit

final class HealthStatusCardCell: UICollectionViewCell {

    static let reuseIdentifier = "HealthStatusCardCell"

    @IBOutlet private weak var firstNameValueLabel: UILabel!
    @IBOutlet private weak var lastNameValueLabel: UILabel!
    @IBOutlet private weak var diagnosisDateValueLabel: UILabel!
    @IBOutlet private weak var genderValueLabel: UILabel!
    @IBOutlet private weak var ageValueLabel: UILabel!
    @IBOutlet private weak var cancerStageValueLabel: UILabel!
    @IBOutlet private weak var treatmentStateValueLabel: UILabel!

    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var diagnosisDateTextField: UITextField!
    @IBOutlet private weak var genderTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var cancerStageTextField: UITextField!
    @IBOutlet private weak var treatmentStateTextField: UITextField!

    private lazy var valueLabels: [UILabel] = [
        firstNameValueLabel,
        lastNameValueLabel,
        diagnosisDateValueLabel,
        genderValueLabel,
        ageValueLabel,
        cancerStageValueLabel,
        treatmentStateValueLabel
    ]

    private lazy var editableFields: [UITextField] = [
        firstNameTextField,
        lastNameTextField,
        diagnosisDateTextField,
        genderTextField,
        ageTextField,
        cancerStageTextField,
        treatmentStateTextField
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        editableFields.forEach {
            $0.borderStyle = .none
            $0.backgroundColor = .clear
            $0.textColor = .systemBlue
            $0.textAlignment = .right
        }
        setEditing(false)
    }

    func configure(
        firstName: String,
        lastName: String,
        diagnosisDate: String,
        gender: String,
        age: String,
        cancerStage: String,
        treatmentState: String
    ) {
        let values = [
            firstName,
            lastName,
            diagnosisDate,
            gender,
            age,
            cancerStage,
            treatmentState
        ]

        zip(valueLabels, values).forEach { $0.text = $1 }
        zip(editableFields, values).forEach { $0.text = $1 }
    }

    func setEditing(_ editing: Bool) {
        valueLabels.forEach { $0.isHidden = editing }
        editableFields.forEach { $0.isHidden = !editing }
    }

    func commitEdits() {
        zip(editableFields, valueLabels).forEach { $1.text = $0.text }
    }

    func revertEdits() {
        zip(valueLabels, editableFields).forEach { $1.text = $0.text }
    }

    var currentName: (first: String, last: String)? {
        guard
            let first = firstNameTextField.text,
            let last = lastNameTextField.text
        else {
            return nil
        }
        return (first, last)
    }
}
