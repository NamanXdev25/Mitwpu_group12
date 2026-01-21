import UIKit

// MARK: - Delegate Protocol
protocol SignUpFormCellDelegate: AnyObject {
    func signUpFormCellDidTapSignUp(_ cell: SignUpFormCell, email: String, password: String, reenterPassword: String, agreedToTerms: Bool)
}

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

    // MARK: - Delegate
    weak var delegate: SignUpFormCellDelegate?

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

    /// 🔥 Sign Up - Now calls delegate
    @IBAction func signUpTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let reenterPassword = reenterPasswordTextField.text ?? ""
        
        // Basic validation
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
        
        // Call delegate
        delegate?.signUpFormCellDidTapSignUp(self, email: email, password: password, reenterPassword: reenterPassword, agreedToTerms: isChecked)
    }
    
    private func showAlert(message: String) {
        // Find the parent view controller
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
    static let brandPink = UIColor(named: "Pink")!
}
