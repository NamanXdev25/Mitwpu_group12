//
//  CompletionViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 14/01/26.
//

import UIKit

class CompletionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var titleLabel: UILabel! // "You're all set, Sophie!"
    @IBOutlet weak var homeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Animate progress bar to 100% (complete!)
        progressBar.setProgress(currentStep: 4, totalSteps: 4, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        
        // Personalize with user's name
        let userName = OnboardingData.shared.userName
        titleLabel.text = "You're all set,\n\(userName)!"
    }
    
    // MARK: - Actions
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        print("🏠 Going to Home Screen")
        print("📊 Onboarding Data Summary:")
        print("- Treatment Status: \(OnboardingData.shared.treatmentStatus ?? "None")")
        print("- Diagnosis Date: \(OnboardingData.shared.diagnosisDate?.description ?? "None")")
        print("- Age: \(OnboardingData.shared.currentAge ?? "None")")
        print("- Stage: \(OnboardingData.shared.currentStage ?? "None")")
        print("- Hobbies: \(OnboardingData.shared.selectedHobbies)")
        
        // TODO: Navigate to main app (we'll do this later)
        // For now, dismiss to root
        navigationController?.dismiss(animated: true)
    }
}
