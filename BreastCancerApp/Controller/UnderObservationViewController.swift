//
//  UnderObservationViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class UnderObservationViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lastCheckupDatePicker: UIDatePicker!
    @IBOutlet weak var followUpButton: UIButton!
    @IBOutlet weak var followUpPickerView: UIView!
    @IBOutlet weak var followUpPicker: UIPickerView!
    @IBOutlet weak var overlayView: UIView! // overlay for dimming & tap gesture
    
    private var selectedFollowUpFrequency: String?
    private let frequencyOptions = OnboardingDataSource.followUpFrequencies
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickers()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 3, totalSteps: 5, animated: true)
    }
    
    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButtonState()
        
        lastCheckupDatePicker.maximumDate = Date()
        lastCheckupDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        overlayView.isHidden = true
        overlayView.alpha = 0.5
        followUpPickerView.isHidden = true
    }
    
    private func setupPickers() {
        followUpPicker.delegate = self
        followUpPicker.dataSource = self
    }
    
    private func setupGestures() {
        // tap gesture for overlay
        let overlayTap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(overlayTap)
    }
    
    @IBAction func followUpButtonTapped(_ sender: UIButton) {
        overlayView.isHidden = false
        followUpPickerView.isHidden = false
        
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(followUpPickerView)
    }
    
    @objc private func overlayTapped() {
        overlayView.isHidden = true
        followUpPickerView.isHidden = true
    }
    
    @objc private func datePickerChanged() {
        updateNextButtonState()
    }
    
    private func updateNextButtonState() {
        let hasFrequency = selectedFollowUpFrequency != nil
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
        
        // navigate to hobbies screen
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveData()
        print("Under Observation data saved:")
        print("- Last Checkup: \(lastCheckupDatePicker.date)")
        print("- Follow-up Frequency: \(selectedFollowUpFrequency ?? "none")")
        
        // navigate to hobbies screen
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

// delegate & datasource
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
        var config = followUpButton.configuration ?? UIButton.Configuration.plain()
        config.title = selectedFollowUpFrequency
        followUpButton.configuration = config
        
        updateNextButtonState()
    }
}
