
import UIKit

class CompletionViewController: UIViewController {

    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        transferOnboardingDataToProfile()

        seedJourneyStateFromOnboarding()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 9, totalSteps: 9, animated: true)
    }

    // MARK: - UI setup
    private func setupUI() {
        progressBar.setProgress(4, animated: false)

        let userName = OnboardingData.shared.userName
        let firstName = userName.components(separatedBy: " ").first ?? "User"
        titleLabel.text = "You're all set,\n\(firstName)!"
    }

    private func transferOnboardingDataToProfile() {
        UserProfileDataSource.shared.transferFromOnboarding()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        if AppBackend.current == .supabase {
            SupabaseAuthService.shared.markCurrentUserOnboardingCompleted()
        }
    }

    // MARK: - Seed JourneyState from onboarding answers
    private func seedJourneyStateFromOnboarding() {
        let data = OnboardingData.shared
        guard let status = data.treatmentStatus else { return }

        let js = JourneyState.shared

        guard !js.isDiagnosisCompleted else { return }

        switch status {

        case "Currently in treatment":
            js.saveDiagnosisState(date: data.diagnosisDate)
            js.completeDiagnosis()
            js.completeWait()
            let phaseName = data.currentTreatmentPhase ?? "Treatment"
            js.updateTreatmentPhaseName(phaseName)

        case "Post-treatment / in recovery":
            js.saveDiagnosisState(date: data.diagnosisDate)
            js.completeDiagnosis()
            js.completeWait()
            js.completeTreatment(phaseName: data.currentTreatmentPhase ?? "Treatment")

        default:
            break
        }
    }

    @IBAction func homeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "TabbarMain", bundle: nil)

        guard let tabBarController =
                storyboard.instantiateInitialViewController()
                as? UITabBarController else {
            fatalError("TabBarMain must have UITabBarController as initial VC")
        }

        if let sceneDelegate =
            UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()

        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "None" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
