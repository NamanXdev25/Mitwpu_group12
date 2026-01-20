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
    private var isPasswordVisible = false
    private var isChecked = false

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
        setupContainers()
        setupSignUpButton()
        setupCheckboxButton()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isChecked = false
        updateCheckboxUI()
    }

    // MARK: - TextField Setup
    private func setupTextFields() {
        emailTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
        reenterPasswordTextField.borderStyle = .none

        passwordTextField.isSecureTextEntry = true
        reenterPasswordTextField.isSecureTextEntry = true
    }

    // MARK: - Container Styling
    private func setupContainers() {
        let containers = [
            emailContainerView,
            passwordContainerView,
            reenterPasswordContainerView
        ]

        containers.forEach { view in
            guard let view = view else { return }
            view.layer.cornerRadius = 12
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemPink.cgColor
            view.backgroundColor = .white
            view.clipsToBounds = true
        }
    }

    // MARK: - Sign Up Button Styling
    private func setupSignUpButton() {
        signUpButton.backgroundColor = .systemPink
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 28
        signUpButton.clipsToBounds = true
    }

    // MARK: - Checkbox Setup (iOS 15+ SAFE)
    private func setupCheckboxButton() {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .systemPink
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 6, leading: 6, bottom: 6, trailing: 6
        )
        agreeButton.configuration = config
        updateCheckboxUI()
    }

    private func updateCheckboxUI() {
        var config = agreeButton.configuration ?? UIButton.Configuration.plain()
        config.image = UIImage(
            systemName: isChecked
                ? "checkmark.square.fill"
                : "square"
        )
        config.baseForegroundColor = .systemPink
        agreeButton.configuration = config
    }

    // MARK: - Actions

    /// Checkbox toggle
    @IBAction func agreeTapped(_ sender: UIButton) {
        isChecked.toggle()
        updateCheckboxUI()
    }

    /// Password visibility toggle
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        reenterPasswordTextField.isSecureTextEntry = !isPasswordVisible
    }

    /// Sign Up action
    @IBAction func signUpTapped(_ sender: UIButton) {
        print("Email:", emailTextField.text ?? "")
        print("Password:", passwordTextField.text ?? "")
        print("Agreed:", isChecked)
    }
}
