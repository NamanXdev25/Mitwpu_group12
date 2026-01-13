//
//  PostTreatmentViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class PostTreatmentViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 3, totalSteps: 4, animated: true)
    }
    
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped - Post Treatment")
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        print("Next tapped - Post Treatment")
        // Will navigate to common screen
    }
}
