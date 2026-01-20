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

        // Optional: persist onboarding completion later
        // UserDefaults.standard.set(true, forKey: "didCompleteOnboarding")

        let storyboard = UIStoryboard(name: "Home", bundle: nil)

        guard let homeNav = storyboard.instantiateInitialViewController() as? UINavigationController else {
            fatalError("Home storyboard must have a Navigation Controller as initial VC")
        }

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = homeNav
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
