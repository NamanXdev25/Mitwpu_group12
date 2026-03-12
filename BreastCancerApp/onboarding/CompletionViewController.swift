//
//  CompletionViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 14/01/26.
//

import UIKit

class CompletionViewController: UIViewController {

    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Transfer onboarding data to user profile
        transferOnboardingDataToProfile()

        // Seed JourneyState so the Home journey card reflects onboarding answers
        seedJourneyStateFromOnboarding()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 9, totalSteps: 9, animated: true)
    }

    // MARK: - UI setup
    private func setupUI() {
        progressBar.setProgress(4, animated: false)

        // Personalize with user's first name only
        let userName = OnboardingData.shared.userName
        let firstName = userName.components(separatedBy: " ").first ?? "User"
        titleLabel.text = "You're all set,\n\(firstName)!"
    }

    private func transferOnboardingDataToProfile() {
        print("Starting onboarding data transfer...")
        UserProfileDataSource.shared.transferFromOnboarding()
        print("Onboarding data successfully transferred to profile")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        if AppBackend.current == .supabase {
            SupabaseAuthService.shared.markCurrentUserOnboardingCompleted()
        }
    }

    // MARK: - Seed JourneyState from onboarding answers
    // This runs once after onboarding so the Home journey card
    // immediately reflects what the user told us about their status.
    private func seedJourneyStateFromOnboarding() {
        let data = OnboardingData.shared
        guard let status = data.treatmentStatus else { return }

        let js = JourneyState.shared

        // Don't overwrite if the user has already interacted with the Journey screen
        guard !js.isDiagnosisCompleted else { return }

        switch status {

        case "Currently in treatment":
            // Move through Diagnosis → Wait → Treatment
            js.completeDiagnosis()
            js.completeWait()
            // Use the treatment phase they selected (e.g. "Chemotherapy")
            // If not set, fall back to the generic "Treatment" label
            let phaseName = data.currentTreatmentPhase ?? "Treatment"
            js.updateTreatmentPhaseName(phaseName)

        case "Post-treatment / in recovery":
            // Move through all stages to Post-Treatment / Recovery
            js.completeDiagnosis()
            js.completeWait()
            js.completeTreatment(phaseName: data.currentTreatmentPhase ?? "Treatment")

        default:
            // "Prefer not to say" — no journey context to seed, leave at default
            break
        }

        print("✅ JourneyState seeded from onboarding: \(status)")
        print("   currentStepTitle: \(js.currentStepTitle)")
        print("   currentTreatmentName: \(js.currentTreatmentName)")
    }

    @IBAction func homeButtonTapped(_ sender: UIButton) {
        // Navigate to main tab bar
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

            print("Navigated to home screen")
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "None" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
