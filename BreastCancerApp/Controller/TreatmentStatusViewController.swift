//
//  TreatmentStatusViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/01/26.
//

import UIKit

class TreatmentStatusViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Properties
    private var treatmentOptions: [String] = []
    private var selectedIndex: Int? {
        didSet {
            updateNextButtonState()
        }
    }
    private var optionViews: [TreatmentOptionView] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTreatmentOptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Animate progress to 50% (step 2 of 4)
        progressBar.setProgress(currentStep: 2, totalSteps: 4, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButtonState()
    }
    
    private func loadTreatmentOptions() {
        // Get options from datasource
        treatmentOptions = OnboardingDataSource.treatmentOptions
        
        // Create option views
        for (index, option) in treatmentOptions.enumerated() {
            let optionView = TreatmentOptionView()
            optionView.title = option
            optionView.translatesAutoresizingMaskIntoConstraints = false
            optionView.heightAnchor.constraint(equalToConstant: 64).isActive = true
            
            // Handle tap
            optionView.onTap = { [weak self] in
                self?.handleOptionTapped(at: index)
            }
            
            stackView.addArrangedSubview(optionView)
            optionViews.append(optionView)
        }
    }
    
    private func handleOptionTapped(at index: Int) {
        // Deselect all
        optionViews.forEach { $0.isSelectedOption = false }
        
        // Select tapped one
        optionViews[index].isSelectedOption = true
        selectedIndex = index
        
        // Save to model
        OnboardingData.shared.treatmentStatus = treatmentOptions[index]
    }
    
    private func updateNextButtonState() {
        nextButton.isEnabled = selectedIndex != nil
        nextButton.alpha = selectedIndex != nil ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped")
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let index = selectedIndex else { return }
        
        let selectedOption = treatmentOptions[index]
        print("Next tapped - selected: \(selectedOption)")
        
        // Navigate based on selection
        var identifier: String
        
        switch index {
        case 0: // Currently in treatment
            identifier = "showJourneyDetails"
        case 1: // Under Observation
            identifier = "showUnderObservation"
        case 2: // Post-treatment / in recovery
            identifier = "showPostTreatment"
        case 3: // Prefer not to say
            identifier = "showPreferNotToSay"
        default:
            return
        }
        
        performSegue(withIdentifier: identifier, sender: nil)
    }
}
