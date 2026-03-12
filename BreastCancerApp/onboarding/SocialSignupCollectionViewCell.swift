import UIKit

final class SocialSignupCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var googleContainerView: UIView!
    @IBOutlet weak var appleContainerView: UIView!
    @IBOutlet weak var signupContainer: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var donthaveAccountLabel: UILabel!
    
    var onSignInTapped: (() -> Void)?
    var onGoogleTapped: (() -> Void)?
    var onAppleTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureInteraction()
        setupUI()
        setupTapGestures()
    }

    private func configureInteraction() {
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
    }

    private func setupUI() {
        stylePillView(googleContainerView)
        stylePillView(appleContainerView)
    }

    private func stylePillView(_ view: UIView) {
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "Pink")?.cgColor
        view.backgroundColor = .white
        view.clipsToBounds = true
    }

    private func setupTapGestures() {
        let googleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapGoogleContainer)
        )
        googleContainerView.addGestureRecognizer(googleTap)

        let appleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapAppleContainer)
        )
        appleContainerView.addGestureRecognizer(appleTap)
    }

    @objc
    private func didTapGoogleContainer() {
        onGoogleTapped?()
    }

    @objc
    private func didTapAppleContainer() {
        onAppleTapped?()
    }


    @IBAction func didTapGoogle(_ sender: UIButton) {
        onGoogleTapped?()
    }

    @IBAction func didTapApple(_ sender: UIButton) {
        onAppleTapped?()
    }

    @IBAction func didTapSignUp(_ sender: UIButton) {
        onSignInTapped?()
    }
}
