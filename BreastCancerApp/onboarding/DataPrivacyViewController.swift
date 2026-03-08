import UIKit

class DataPrivacyViewController: UIViewController {

    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var letsBeginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setProgress(0, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 4, totalSteps: 9, animated: true)
    }

    @IBAction func letsBeginButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showTreatmentStatus", sender: nil)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "TabbarMain", bundle: nil)
        guard let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController else {
            fatalError("TabBarMain must have UITabBarController as initial VC")
        }
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}
