import UIKit

class SignUpFormCell: UICollectionViewCell {

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
    private var isChecked = false   // ✅ checkbox state

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupContainers()
        setupLoginButton()
        setupCheckbox()
    }

    // MARK: - UI Setup
    private func setupUI() {
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

        containers.forEach { container in
            guard let view = container else { return }

            view.layer.cornerRadius = 12
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemPink.cgColor
            view.layer.masksToBounds = true
            view.backgroundColor = .white
        }
    }

    // MARK: - Login Button Styling
    private func setupLoginButton() {
        signUpButton.backgroundColor = .systemPink
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 28
        signUpButton.layer.masksToBounds = true
        signUpButton.adjustsImageWhenHighlighted = false
    }

    // MARK: - Checkbox Setup (CODE-ONLY)
    private func setupCheckbox() {
        agreeButton.setImage(UIImage(systemName: "square"), for: .normal)
        agreeButton.tintColor = .systemPink
        agreeButton.adjustsImageWhenHighlighted = false
    }

    // MARK: - Actions

    // ✅ Checkbox toggle (pure code)
    @IBAction func agreeTapped(_ sender: UIButton) {
        isChecked.toggle()

        let imageName = isChecked ? "checkmark.square.fill" : "square"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // 👁 Password visibility toggle
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        reenterPasswordTextField.isSecureTextEntry = !isPasswordVisible
        sender.isSelected = isPasswordVisible
    }

    // 🔐 Sign Up
    @IBAction func signUpTapped(_ sender: UIButton) {
        print("Email:", emailTextField.text ?? "")
        print("Password:", passwordTextField.text ?? "")
        print("Agreed:", isChecked)
    }
}
