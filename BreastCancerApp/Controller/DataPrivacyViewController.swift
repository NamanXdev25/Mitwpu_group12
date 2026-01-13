//
//  DataPrivacyViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class DataPrivacyViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var letsBeginButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Animate progress bar to 25% (step 1 of 4)
        progressBar.setProgress(currentStep: 1, totalSteps: 4, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Initial progress (will be animated in viewDidAppear)
        progressBar.setProgress(0, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped")
        // Will handle skip logic later
    }
}
