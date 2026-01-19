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

        // 🔴 CRITICAL (Safe Area present)
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true

        // TextFields
        emailTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        passwordTextField.isSecureTextEntry = true

        // Borders
        applyBorder(to: emailTextField.superview)
        applyBorder(to: passwordTextField.superview)

        // Eye button
        eyeButton.adjustsImageWhenHighlighted = false

        // ✅ Checkbox — SF Symbols + Pink color
        rememberMeButton.adjustsImageWhenHighlighted = false
        rememberMeButton.tintColor = UIColor(named: "Pink")
        rememberMeButton.setImage(
            UIImage(systemName: "square"),
            for: .normal
        )

        // ✅ Login button — ALWAYS Pink
        loginButton.adjustsImageWhenHighlighted = false
        loginButton.backgroundColor = UIColor(named: "Pink")
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 26
        loginButton.clipsToBounds = true
    }

    private func applyBorder(to view: UIView?) {
        guard let view = view else { return }
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "Pink")?.cgColor
        view.clipsToBounds = true
    }

    // MARK: - Actions

    @IBAction func didTapEyeButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordTextField.isSecureTextEntry.toggle()
    }

    @IBAction func didTapRememberMe(_ sender: UIButton) {
        sender.isSelected.toggle()

        let symbolName = sender.isSelected
            ? "checkmark.square.fill"
            : "square"

        sender.setImage(
            UIImage(systemName: symbolName),
            for: .normal
        )
    }
}
