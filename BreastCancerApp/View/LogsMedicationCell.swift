import UIKit

class LogsMedicationCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var pillNameLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // Closure to handle radio button tap
    var onRadioButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRadioButton()
    }
    
    private func setupRadioButton() {
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
    }
    
    @objc private func radioButtonTapped() {
        onRadioButtonTapped?()
    }
    
    func configure(with model: MedicationModel) {
        pillNameLabel.text = model.pillName
        timeLabel.text = model.time
        instructionLabel.text = model.instruction
        updateRadioButton(isCompleted: model.isCompleted)
    }
    
    private func updateRadioButton(isCompleted: Bool) {
        if isCompleted {
            radioButton.backgroundColor = UIColor(red: 0.910, green: 0.416, blue: 0.573, alpha: 1.0)
            radioButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            radioButton.tintColor = .white
        } else {
            radioButton.backgroundColor = .clear
            radioButton.setImage(nil, for: .normal)
        }
    }
}
