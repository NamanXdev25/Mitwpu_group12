//
//  UnderObservationViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class UnderObservationViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    
    // Date picker for last checkup
    @IBOutlet weak var lastCheckupDatePicker: UIDatePicker!
    
    // Follow-up frequency picker and display
    @IBOutlet weak var followUpButton: UIButton! // The button showing selected frequency
    @IBOutlet weak var followUpPickerView: UIView! // Container for picker
    @IBOutlet weak var followUpPicker: UIPickerView!
    
    // Overlay for dimming
    @IBOutlet weak var overlayView: UIView!
    
    // MARK: - Properties
    private var selectedFollowUpFrequency: String?
    private let frequencyOptions = OnboardingDataSource.followUpFrequencies
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickers()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 3, totalSteps: 4, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButtonState()
        
        // Set max date for last checkup to today
        lastCheckupDatePicker.maximumDate = Date()
        lastCheckupDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        // Hide picker and overlay initially
        overlayView.isHidden = true
        overlayView.alpha = 0.5
        followUpPickerView.isHidden = true
    }
    
    private func setupPickers() {
        // Configure follow-up frequency picker
        followUpPicker.delegate = self
        followUpPicker.dataSource = self
    }
    
    private func setupGestures() {
        // Tap gesture for overlay (to dismiss picker)
        let overlayTap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(overlayTap)
    }
    
    // MARK: - Actions
    @IBAction func followUpButtonTapped(_ sender: UIButton) {
        // Show overlay and picker
        overlayView.isHidden = false
        followUpPickerView.isHidden = false
        
        // Bring to front
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(followUpPickerView)
    }
    
    @objc private func overlayTapped() {
        // Hide overlay and picker
        overlayView.isHidden = true
        followUpPickerView.isHidden = true
    }
    
    @objc private func datePickerChanged() {
        updateNextButtonState()
    }
    
    private func updateNextButtonState() {
        let hasFrequency = selectedFollowUpFrequency != nil
        // Date picker always has a value
        
        let isValid = hasFrequency
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }
    
    private func saveData() {
        OnboardingData.shared.lastCheckupDate = lastCheckupDatePicker.date
        OnboardingData.shared.followUpFrequency = selectedFollowUpFrequency
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped - Under Observation")
        // Navigate to hobbies screen
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveData()
        print("Under Observation data saved:")
        print("- Last Checkup: \(lastCheckupDatePicker.date)")
        print("- Follow-up Frequency: \(selectedFollowUpFrequency ?? "none")")
        
        // Navigate to hobbies screen
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension UnderObservationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequencyOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frequencyOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFollowUpFrequency = frequencyOptions[row]
        
        // Update button title to show selected frequency
        var config = followUpButton.configuration ?? UIButton.Configuration.plain()
        config.title = selectedFollowUpFrequency
        followUpButton.configuration = config
        
        updateNextButtonState()
    }
}
