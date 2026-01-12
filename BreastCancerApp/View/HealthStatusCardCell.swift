import UIKit

final class HealthStatusCardCell: UICollectionViewCell {

    static let reuseIdentifier = "HealthStatusCardCell"

    // MARK: - Value Labels (View Mode)
    @IBOutlet weak var firstNameValueLabel: UILabel!
    @IBOutlet weak var lastNameValueLabel: UILabel!
    @IBOutlet weak var diagnosisDateValueLabel: UILabel!
    @IBOutlet weak var genderValueLabel: UILabel!
    @IBOutlet weak var ageValueLabel: UILabel!
    @IBOutlet weak var cancerStageValueLabel: UILabel!
    @IBOutlet weak var treatmentStateValueLabel: UILabel!

    // MARK: - Editable TextFields (Edit Mode)
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var diagnosisDateTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var cancerStageTextField: UITextField!
    @IBOutlet weak var treatmentStateTextField: UITextField!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTextFields()
        setEditing(false)
    }

    // MARK: - TextField Styling (no gray boxes)
    private func configureTextFields() {
        let fields = [
            firstNameTextField,
            lastNameTextField,
            diagnosisDateTextField,
            genderTextField,
            ageTextField,
            cancerStageTextField,
            treatmentStateTextField
        ]

        fields.forEach {
            $0?.borderStyle = .none
            $0?.backgroundColor = .clear
            $0?.textColor = .systemBlue
            $0?.textAlignment = .right
        }
    }

    // MARK: - Configure Cell
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

    // MARK: - Edit Mode Toggle
    func setEditing(_ editing: Bool) {
        let labels = [
            firstNameValueLabel,
            lastNameValueLabel,
            diagnosisDateValueLabel,
            genderValueLabel,
            ageValueLabel,
            cancerStageValueLabel,
            treatmentStateValueLabel
        ]

        let fields = [
            firstNameTextField,
            lastNameTextField,
            diagnosisDateTextField,
            genderTextField,
            ageTextField,
            cancerStageTextField,
            treatmentStateTextField
        ]

        labels.forEach { $0?.isHidden = editing }
        fields.forEach { $0?.isHidden = !editing }
    }

    // MARK: - Save / Cancel Helpers
    func commitEdits() {
        firstNameValueLabel.text = firstNameTextField.text
        lastNameValueLabel.text = lastNameTextField.text
        diagnosisDateValueLabel.text = diagnosisDateTextField.text
        genderValueLabel.text = genderTextField.text
        ageValueLabel.text = ageTextField.text
        cancerStageValueLabel.text = cancerStageTextField.text
        treatmentStateValueLabel.text = treatmentStateTextField.text
    }

    func revertEdits() {
        firstNameTextField.text = firstNameValueLabel.text
        lastNameTextField.text = lastNameValueLabel.text
        diagnosisDateTextField.text = diagnosisDateValueLabel.text
        genderTextField.text = genderValueLabel.text
        ageTextField.text = ageValueLabel.text
        cancerStageTextField.text = cancerStageValueLabel.text
        treatmentStateTextField.text = treatmentStateValueLabel.text
    }

    // MARK: - Expose Edited Name to ViewController (IMPORTANT)
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
