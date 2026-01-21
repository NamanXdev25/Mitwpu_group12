import UIKit

final class SocialSignupCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var googleContainerView: UIView!
    @IBOutlet weak var appleContainerView: UIView!
    @IBOutlet weak var signupContainer: UIView!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var donthaveAccountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureInteraction()
        setupUI()
    }

    private func configureInteraction() {
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
    }

    private func setupUI() {
        stylePillView(googleContainerView)
        stylePillView(appleContainerView)

        signUpButton.backgroundColor = .clear
        signUpButton.setTitleColor(UIColor(named: "pink"), for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    private func stylePillView(_ view: UIView) {
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "pink")?.cgColor
        view.backgroundColor = .white
        view.clipsToBounds = true
    }

    // Actions

    @IBAction func didTapGoogle(_ sender: UIButton) {
        print("Google login tapped")
    }

    @IBAction func didTapApple(_ sender: UIButton) {
        print("Apple login tapped")
    }

    @IBAction func didTapSignUp(_ sender: UIButton) {
        print("Sign up tapped")
    }
}
