
import UIKit

protocol HealthFieldCellDelegate: AnyObject {
    func healthFieldCell(_ cell: HealthFieldCell, didChangeText text: String)
}

class HealthFieldCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!

    weak var delegate: HealthFieldCellDelegate?

    private var brandPink: UIColor {
        UIColor(named: "BrandPink") ?? UIColor(red: 215/255, green: 112/255, blue: 145/255, alpha: 1)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        valueTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    func configure(title: String, value: String, isEditing: Bool) {
        backgroundColor             = .clear
        contentView.backgroundColor = .clear

        titleLabel.text      = title
        titleLabel.font      = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .label

        valueTextField.text                     = value
        valueTextField.borderStyle              = .none
        valueTextField.backgroundColor          = .clear
        valueTextField.isUserInteractionEnabled = isEditing
        valueTextField.font                     = .systemFont(ofSize: 15, weight: .regular)
        valueTextField.textAlignment            = .right
        valueTextField.textColor                = isEditing ? brandPink : .label
    }

    @objc private func textChanged() {
        delegate?.healthFieldCell(self, didChangeText: valueTextField.text ?? "")
    }
}
