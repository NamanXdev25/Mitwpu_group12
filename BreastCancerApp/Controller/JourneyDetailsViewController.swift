//
//  JourneyDetailsViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class JourneyDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    
    // Date picker and display
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Age picker and display - CHANGED TO UIButton
    @IBOutlet weak var ageLabel: UIButton! // The button that shows selected age with chevron
    @IBOutlet weak var agePickerView: UIView! // Container view for age picker
    @IBOutlet weak var agePicker: UIPickerView!
    
    // Stage picker and display - CHANGED TO UIButton
    @IBOutlet weak var stageLabel: UIButton! // The button that shows selected stage with chevron
    @IBOutlet weak var stagePickerView: UIView! // Container view for stage picker
    @IBOutlet weak var stagePicker: UIPickerView!
    
    // Overlay for dimming
    @IBOutlet weak var overlayView: UIView!
    
    // MARK: - Properties
    private var selectedAge: String?
    private var selectedStage: String?
    
    private let ageOptions = OnboardingDataSource.ageGroups
    private let stageOptions = OnboardingDataSource.cancerStages
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // "13 Jan 2026" format
        return formatter
    }()
    
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
        
        // Set max date for date picker to today
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        // Hide pickers and overlay initially
        overlayView.isHidden = true
        overlayView.alpha = 0.5 // Make overlay semi-transparent
        agePickerView.isHidden = true
        stagePickerView.isHidden = true
    }
    
    private func setupPickers() {
        // Configure age picker
        agePicker.delegate = self
        agePicker.dataSource = self
        agePicker.tag = 1 // Age picker
        
        // Configure stage picker
        stagePicker.delegate = self
        stagePicker.dataSource = self
        stagePicker.tag = 2 // Stage picker
    }
    
    private func setupGestures() {
        // Tap gesture for overlay (to dismiss pickers)
        let overlayTap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(overlayTap)
    }
    
    // MARK: - Actions
    @IBAction func ageFieldTapped(_ sender: UIButton) {
        // Hide stage picker if visible
        stagePickerView.isHidden = true
        
        // Show overlay and age picker
        overlayView.isHidden = false
        agePickerView.isHidden = false
        
        // Bring to front
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(agePickerView)
    }
    
    @IBAction func stageFieldTapped(_ sender: UIButton) {
        // Hide age picker if visible
        agePickerView.isHidden = true
        
        // Show overlay and stage picker
        overlayView.isHidden = false
        stagePickerView.isHidden = false
        
        // Bring to front
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(stagePickerView)
    }
    
    @objc private func overlayTapped() {
        // Hide overlay and all pickers
        overlayView.isHidden = true
        agePickerView.isHidden = true
        stagePickerView.isHidden = true
    }
    
    @objc private func datePickerChanged() {
        updateNextButtonState()
    }
    
    private func updateNextButtonState() {
        let hasAge = selectedAge != nil
        let hasStage = selectedStage != nil
        // Date picker always has a value, so we consider it filled
        
        let isValid = hasAge && hasStage
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }
    
    private func saveData() {
        OnboardingData.shared.diagnosisDate = datePicker.date
        OnboardingData.shared.currentAge = selectedAge
        OnboardingData.shared.currentStage = selectedStage
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        print("Skip tapped")
        // Navigate to end or next screen
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveData()
        print("Journey details saved:")
        print("- Date: \(datePicker.date)")
        print("- Age: \(selectedAge ?? "none")")
        print("- Stage: \(selectedStage ?? "none")")
        // Will navigate to hobbies screen
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension JourneyDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 { // Age picker
            return ageOptions.count
        } else { // Stage picker
            return stageOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return ageOptions[row]
        } else {
            return stageOptions[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 { // Age
            selectedAge = ageOptions[row]
            
            // Update button title to show selected age
            var config = ageLabel.configuration ?? UIButton.Configuration.plain()
            config.title = selectedAge
            config.imagePlacement = .trailing
            config.image = UIImage(systemName: "chevron.up.chevron.down")
            ageLabel.configuration = config
            ageLabel.tintColor = UIColor(named: "OnboardingPrimaryColor")
            
            // Auto-dismiss after selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.overlayTapped()
            }
        } else { // Stage
            selectedStage = stageOptions[row]
            
            // Update button title to show selected stage
            var config = stageLabel.configuration ?? UIButton.Configuration.plain()
            config.title = selectedStage
            config.imagePlacement = .trailing
            config.image = UIImage(systemName: "chevron.up.chevron.down")
            stageLabel.configuration = config
            stageLabel.tintColor = UIColor(named: "OnboardingPrimaryColor")
            
            // Auto-dismiss after selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.overlayTapped()
            }
        }
        
        updateNextButtonState()
    }
}
