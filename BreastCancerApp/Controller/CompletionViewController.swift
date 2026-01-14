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
        print("Going to Home Screen")
        print("Onboarding Data Summary:")
        print("========================================")
        
        // Common data
        print("✓ Treatment Status: \(OnboardingData.shared.treatmentStatus ?? "None")")
        print("✓ Selected Hobbies: \(OnboardingData.shared.selectedHobbies)")
        
        // Conditional data based on treatment status
        if let treatmentStatus = OnboardingData.shared.treatmentStatus {
            print("\nTreatment-Specific Data:")
            
            switch treatmentStatus {
            case "Currently in treatment":
                print("  - Diagnosis Date: \(formatDate(OnboardingData.shared.diagnosisDate))")
                print("  - Current Age: \(OnboardingData.shared.currentAge ?? "None")")
                print("  - Current Stage: \(OnboardingData.shared.currentStage ?? "None")")
                
            case "Under Observation":
                print("  - Last Checkup Date: \(formatDate(OnboardingData.shared.lastCheckupDate))")
                print("  - Follow-up Frequency: \(OnboardingData.shared.followUpFrequency ?? "None")")
                
            case "Post-treatment / in recovery":
                print("  - Treatment Completion Date: \(formatDate(OnboardingData.shared.treatmentCompletionDate))")
                print("  - Focus Areas: \(OnboardingData.shared.selectedInterests)")
                
            case "Prefer not to say":
                print("  - Areas of Interest: \(OnboardingData.shared.selectedInterests)")
                
            default:
                print("  - No additional data")
            }
        }
        
        print("========================================")
        print("Onboarding Complete!")
        
        // TODO: Navigate to main app (we'll do this later)
        // For now, dismiss to root
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Helper Methods
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "None" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
