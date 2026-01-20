import UIKit

final class SignUpFormCell: UICollectionViewCell {

    // MARK: - Container Views
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var reenterPasswordContainerView: UIView!

    // MARK: - TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!

    // MARK: - Buttons
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    // MARK: - State
    private var isChecked: Bool = false
    private var isPasswordVisible: Bool = false

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        agreeButton.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        agreeButton.layer.zPosition = 999

        configureInteraction()
        configureTextFields()
        configureContainers()
        configureCheckbox()
        configureSignUpButton()
    }

    // MARK: - Interaction (VERY IMPORTANT)
    private func configureInteraction() {
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        agreeButton.isUserInteractionEnabled = true
    }

    // MARK: - TextFields
    private func configureTextFields() {
        emailTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
        reenterPasswordTextField.borderStyle = .none

        passwordTextField.isSecureTextEntry = true
        reenterPasswordTextField.isSecureTextEntry = true
    }

    // MARK: - Containers
    private func configureContainers() {
        let containers = [
            emailContainerView,
            passwordContainerView,
            reenterPasswordContainerView
        ]

        containers.forEach { view in
            view?.layer.cornerRadius = 12
            view?.layer.borderWidth = 1
            view?.layer.borderColor = UIColor.systemPink.cgColor
            view?.backgroundColor = .white
            view?.clipsToBounds = true
        }
    }

    // MARK: - Checkbox Setup (NO deprecated APIs)
    private func configureCheckbox() {
        agreeButton.backgroundColor = .clear
        agreeButton.tintColor = .systemPink
        agreeButton.setImage(
            UIImage(systemName: "square"),
            for: .normal
        )
    }

    // MARK: - Sign Up Button
    private func configureSignUpButton() {
        signUpButton.backgroundColor = .systemPink
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 28
        signUpButton.clipsToBounds = true
    }

    // MARK: - Actions

    /// ✅ Checkbox Tap (WORKING, RELIABLE)
    @IBAction func agreeTapped(_ sender: UIButton) {
        isChecked.toggle()

        if isChecked {
            // Pink box + white tick
            sender.setImage(
                UIImage(systemName: "checkmark.square.fill"),
                for: .normal
            )
            sender.tintColor = .white
            sender.backgroundColor = .systemPink
        } else {
            // Empty square
            sender.setImage(
                UIImage(systemName: "square"),
                for: .normal
            )
            sender.tintColor = .systemPink
            sender.backgroundColor = .clear
        }
    }

    /// 👁 Toggle password visibility
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        reenterPasswordTextField.isSecureTextEntry = !isPasswordVisible
    }

    /// 🔐 Sign Up
    @IBAction func signUpTapped(_ sender: UIButton) {
        print("Email:", emailTextField.text ?? "")
        print("Password:", passwordTextField.text ?? "")
        print("Agreed:", isChecked)
    }
}
