import UIKit

class SignUpSocialCell: UICollectionViewCell {

    // Google
    @IBOutlet weak var googleContainerView: UIView!
    @IBOutlet weak var googleIconImageView: UIImageView!
    @IBOutlet weak var googleButton: UIButton!

    // Apple
    @IBOutlet weak var appleContainerView: UIView!
    @IBOutlet weak var appleIconImageView: UIImageView!
    @IBOutlet weak var appleButton: UIButton!

    // Bottom Row
    @IBOutlet weak var haveAccountLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!

    // Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // UI Setup
    private func setupUI() {
        setupContainers()
        setupButtons()
        setupBottomRow()
    }

    // Container Styling
    private func setupContainers() {
        [googleContainerView, appleContainerView].forEach { container in
            guard let view = container else { return }

            view.layer.cornerRadius = 26
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemPink.cgColor
            view.layer.masksToBounds = true
            view.backgroundColor = .white
        }
    }

    // Buttons
    private func setupButtons() {
        googleButton.setTitle("Continue with Google", for: .normal)
        googleButton.setTitleColor(.black, for: .normal)
        googleButton.contentHorizontalAlignment = .left
        googleButton.backgroundColor = .clear

        appleButton.setTitle("Continue with Apple", for: .normal)
        appleButton.setTitleColor(.black, for: .normal)
        appleButton.contentHorizontalAlignment = .left
        appleButton.backgroundColor = .clear
    }

    // Bottom Row
    private func setupBottomRow() {
        haveAccountLabel.text = "Have an account?"
        haveAccountLabel.textColor = .gray
        haveAccountLabel.font = UIFont.systemFont(ofSize: 14)

        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(.systemPink, for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        signInButton.backgroundColor = .clear
    }
}
