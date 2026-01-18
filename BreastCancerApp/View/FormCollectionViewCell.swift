//
//  FormCollectionViewCell.swift
//  BreastCancerApp
//
//  Created by Shloka on 18/01/26.
//

import UIKit

class FormCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        emailTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        passwordTextField.isSecureTextEntry = true

        eyeButton.setImage(UIImage(named: "icon_eye_closed"), for: .normal)

        rememberMeButton.setImage(UIImage(named: "icon_checkbox_unchecked"), for: .normal)
        rememberMeButton.setImage(UIImage(named: "icon_checkbox_checked"), for: .selected)

        
        loginButton.backgroundColor = UIColor.systemPink
        loginButton.layer.cornerRadius = 26
        loginButton.clipsToBounds = true
    }


    @IBAction func didTapEyeButton(_ sender: UIButton) {
        sender.isSelected.toggle()

        passwordTextField.isSecureTextEntry.toggle()

        let imageName = sender.isSelected ? "icon_eye_open" : "icon_eye_closed"
        sender.setImage(UIImage(named: imageName), for: .normal)
    }

    @IBAction func didTapRememberMe(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}
