//
//  JourneyDetailsViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/01/26.
//

import UIKit

class JourneyDetailsViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var agePickerView: UIView!
    @IBOutlet weak var agePicker: UIPickerView!
    @IBOutlet weak var stageButton: UIButton!
    @IBOutlet weak var stagePickerView: UIView!
    @IBOutlet weak var stagePicker: UIPickerView!
    @IBOutlet weak var overlayView: UIView!
    
    private var selectedAge: String?
    private var selectedStage: String?
    
    private let ageOptions = OnboardingDataSource.ageGroups
    private let stageOptions = OnboardingDataSource.cancerStages
    
    // override funcs
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
        
        datePicker.maximumDate = Date() // set max date to today
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        overlayView.isHidden = true
        overlayView.alpha = 0.5
        agePickerView.isHidden = true
        stagePickerView.isHidden = true
    }
    
    private func setupPickers() {
        agePicker.delegate = self
        agePicker.dataSource = self
        agePicker.tag = 1 // age picker
        
        stagePicker.delegate = self
        stagePicker.dataSource = self
        stagePicker.tag = 2 // stage picker
    }
    
    private func setupGestures() {
        // tap gesture for overlay
        let overlayTap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(overlayTap)
    }
    
    @IBAction func ageFieldTapped(_ sender: UIButton) {
        stagePickerView.isHidden = true
        overlayView.isHidden = false
        agePickerView.isHidden = false
        
        // bring to front
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(agePickerView)
    }
    
    @IBAction func stageFieldTapped(_ sender: UIButton) {
        agePickerView.isHidden = true
        overlayView.isHidden = false
        stagePickerView.isHidden = false
        
        // bring to front
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(stagePickerView)
    }
    
    @objc private func overlayTapped() {
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
        // navigate to hobbies
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveData()
        print("Journey details saved:")
        print("- Date: \(datePicker.date)")
        print("- Age: \(selectedAge ?? "none")")
        print("- Stage: \(selectedStage ?? "none")")
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

// delegate & datasource
extension JourneyDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return ageOptions.count
        } else {
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
        if pickerView.tag == 1 {
            selectedAge = ageOptions[row]
            // update button title to show selected age
            var config = ageButton.configuration ?? UIButton.Configuration.plain()
            config.title = selectedAge
            ageButton.configuration = config

        } else {
            selectedStage = stageOptions[row]
            // update button title to show selected stage
            var config = stageButton.configuration ?? UIButton.Configuration.plain()
            config.title = selectedStage
            stageButton.configuration = config
            
        }
        
        updateNextButtonState()
    }
}
