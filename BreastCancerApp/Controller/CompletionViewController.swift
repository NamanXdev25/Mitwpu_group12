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
        
        // Transfer onboarding data to user profile
        transferOnboardingDataToProfile()
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
    
    // MARK: - Data Transfer
    
    /// Transfers all onboarding data to the user profile system
    private func transferOnboardingDataToProfile() {
        print("🔄 Starting onboarding data transfer...")
        
        // Use the centralized transfer method
        UserProfileDataSource.shared.transferFromOnboarding()
        
        print("✅ Onboarding data successfully transferred to profile")
        
        // Optional: Mark onboarding as completed in UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        // Navigate to main tab bar
        let storyboard = UIStoryboard(name: "TabBarMain", bundle: nil)

        guard let tabBarController =
                storyboard.instantiateInitialViewController()
                as? UITabBarController else {
            fatalError("TabBarMain must have UITabBarController as initial VC")
        }

        if let sceneDelegate =
            UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
            
            print("🏠 Navigated to home screen")
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "None" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
