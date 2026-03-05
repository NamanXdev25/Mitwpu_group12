//
//  NewAppointmentTextFieldCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 04/03/26.
//

import UIKit

class NewAppointmentTextFieldCell: UICollectionViewCell {

    @IBOutlet weak var textField: UITextField!

    var onTextChange: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    func configure(placeholder: String, text: String?) {
        textField.placeholder = placeholder
        textField.text = (text?.isEmpty == false) ? text : nil
    }

    @objc private func textChanged() {
        onTextChange?(textField.text ?? "")
    }
}
