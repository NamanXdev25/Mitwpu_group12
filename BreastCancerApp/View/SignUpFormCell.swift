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
       

        configureInteraction()
        configureTextFields()
        configureContainers()
        configureCheckbox()
        //configureSignUpButton()
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
            view?.layer.borderColor = UIColor.brandPink.cgColor
            view?.backgroundColor = .white
            view?.clipsToBounds = true
        }
    }

    // MARK: - Checkbox Setup
    private func configureCheckbox() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "square")
        config.baseForegroundColor = .brandPink
        config.background.backgroundColor = .clear
        config.contentInsets = .zero

        agreeButton.configuration = config
    }



    // MARK: - Sign Up Button
//    private func configureSignUpButton() {
//        signUpButton.backgroundColor = .brandPink
//        signUpButton.setTitleColor(.white, for: .normal)
//        //signUpButton.layer.cornerRadius = 28
//        signUpButton.clipsToBounds = true
//    }

    @IBAction func agreeTapped(_ sender: UIButton) {
        isChecked.toggle()

        guard var config = sender.configuration else { return }

        config.image = UIImage(
            systemName: isChecked ? "checkmark.square.fill" : "square"
        )
        config.baseForegroundColor = .brandPink
        config.background.backgroundColor = .clear

        sender.configuration = config
    }

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

extension UIColor {
    static let brandPink = UIColor(named: "Pink")!
}
