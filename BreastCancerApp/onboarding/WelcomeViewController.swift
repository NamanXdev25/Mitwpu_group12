import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var introImageView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mask = CAGradientLayer()
        mask.frame = introImageView.bounds
        mask.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        mask.locations = [0.0, 0.45, 1.0]
        introImageView.layer.mask = mask
    }

    override func shouldPerformSegue(withIdentifier _: String, sender _: Any?) -> Bool {
        // Block the storyboard segue so we navigate to SignUp instead
        return false
    }

    @IBAction func continueButtonTapped(_: UIButton) {
        let signupSB = UIStoryboard(name: "signupMain", bundle: nil)
        if let signupVC = signupSB.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signupVC, animated: true)
        }
    }
}
