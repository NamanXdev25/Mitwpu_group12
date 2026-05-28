import UIKit

protocol SignUpFormCellDelegate: AnyObject {
    func signUpFormCellDidTapSignUp(_ cell: SignUpFormCell, email: String, password: String, reenterPassword: String, agreedToTerms: Bool)
}

final class SignUpFormCell: UICollectionViewCell {
    @IBOutlet var emailContainerView: UIView!
    @IBOutlet var passwordContainerView: UIView!
    @IBOutlet var reenterPasswordContainerView: UIView!

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var reenterPasswordTextField: UITextField!

    @IBOutlet var agreeButton: UIButton!
    @IBOutlet var signUpButton: UIButton!

    weak var delegate: SignUpFormCellDelegate?

    private var isChecked: Bool = false
    private var isPasswordVisible: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        configureInteraction()
        configureTextFields()
        configureContainers()
        configureCheckbox()
    }

    private func configureInteraction() {
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        agreeButton.isUserInteractionEnabled = true
    }

    private func configureTextFields() {
        emailTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
        reenterPasswordTextField.borderStyle = .none

        passwordTextField.isSecureTextEntry = true
        reenterPasswordTextField.isSecureTextEntry = true
    }

    private func configureContainers() {
        let containers = [
            emailContainerView,
            passwordContainerView,
            reenterPasswordContainerView,
        ]

        for view in containers {
            view?.layer.cornerRadius = 12
            view?.layer.borderWidth = 1
            view?.layer.borderColor = UIColor.brandPink.cgColor
            view?.backgroundColor = .white
            view?.clipsToBounds = true
        }
    }

    private func configureCheckbox() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "square")
        config.baseForegroundColor = .brandPink
        config.background.backgroundColor = .clear
        config.contentInsets = .zero

        agreeButton.configuration = config
    }

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

    @IBAction func togglePasswordVisibility(_: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        reenterPasswordTextField.isSecureTextEntry = !isPasswordVisible
    }

    @IBAction func signUpTapped(_: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let reenterPassword = reenterPasswordTextField.text ?? ""

        guard !email.isEmpty else {
            showAlert(message: "Please enter your email")
            return
        }

        guard !password.isEmpty else {
            showAlert(message: "Please enter a password")
            return
        }

        guard password == reenterPassword else {
            showAlert(message: "Passwords don't match")
            return
        }

        guard isChecked else {
            showAlert(message: "Please agree to terms and conditions")
            return
        }

        delegate?.signUpFormCellDidTapSignUp(self, email: email, password: password, reenterPassword: reenterPassword, agreedToTerms: isChecked)
    }

    private func showAlert(message: String) {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let viewController = next as? UIViewController {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                viewController.present(alert, animated: true)
                return
            }
            responder = next
        }
    }
}

extension UIColor {
    static let brandPink = UIColor(named: "primary_color") ?? UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
}
