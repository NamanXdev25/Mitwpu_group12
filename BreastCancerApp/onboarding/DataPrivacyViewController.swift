//
//  DataPrivacyViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class DataPrivacyViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var letsBeginButton: UIButton!
    
    // override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 1, totalSteps: 5, animated: true)
    }
    
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped")
        // navigate to home screen
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
        }
    }
}
