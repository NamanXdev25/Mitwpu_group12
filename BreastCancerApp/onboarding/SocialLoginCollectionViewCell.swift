
import UIKit

class SocialLoginCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var googleContainerView: UIView!
    @IBOutlet weak var appleContainerView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var onSignUpTapped: (() -> Void)?
    var onGoogleTapped: (() -> Void)?
    var onAppleTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTapGestures()
    }

    private func setupUI() {

        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        stylePillView(googleContainerView)
        stylePillView(appleContainerView)
    }

    private func stylePillView(_ view: UIView) {
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "Pink")?.cgColor
        view.clipsToBounds = true
        view.backgroundColor = .white
    }

    private func setupTapGestures() {
        let googleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapGoogle)
        )
        googleContainerView.addGestureRecognizer(googleTap)

        let appleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapApple)
        )
        appleContainerView.addGestureRecognizer(appleTap)
    }

    @objc private func didTapGoogle() {
        onGoogleTapped?()
    }

    @objc private func didTapApple() {
        onAppleTapped?()
    }

    @IBAction func didTapSignUp(_ sender: UIButton) {
        onSignUpTapped?()
    }
}
