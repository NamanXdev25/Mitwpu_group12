//
//  WelcomeViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Any additional setup if needed
        // Most styling is done in Storyboard
    }
}
