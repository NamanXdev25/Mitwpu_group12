//
//  CompletionViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 14/01/26.
//

import UIKit

class CompletionViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 5, totalSteps: 5, animated: true)
    }
    
    // UI setup
    private func setupUI() {
        progressBar.setProgress(4, animated: false)
        
        // personalize with user's name
        let userName = OnboardingData.shared.userName
        titleLabel.text = "You're all set,\n\(userName)!"
    }
    
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        print("Going to Home Screen")
        print("Onboarding Data Summary:")
        print("========================================")
        
        print("Treatment Status: \(OnboardingData.shared.treatmentStatus ?? "None")")
        print("Selected Hobbies: \(OnboardingData.shared.selectedHobbies)")
        
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
        
        navigationController?.popToRootViewController(animated: true)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "None" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
