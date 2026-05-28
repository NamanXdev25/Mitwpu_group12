import UIKit

class UnderObservationViewController: UIViewController {
    @IBOutlet var progressBar: ProgressBarView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var lastCheckupDatePicker: UIDatePicker!
    @IBOutlet var followUpButton: UIButton!
    @IBOutlet var followUpPickerView: UIView!
    @IBOutlet var followUpPicker: UIPickerView!
    @IBOutlet var overlayView: UIView!

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
        let overlayTap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(overlayTap)
    }

    @IBAction func followUpButtonTapped(_: UIButton) {
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

    @IBAction func skipButtonTapped(_: UIButton) {
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }

    @IBAction func nextButtonTapped(_: UIButton) {
        saveData()

        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

extension UnderObservationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return frequencyOptions.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return frequencyOptions[row]
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedFollowUpFrequency = frequencyOptions[row]
        var config = followUpButton.configuration ?? UIButton.Configuration.plain()
        config.title = selectedFollowUpFrequency
        followUpButton.configuration = config

        updateNextButtonState()
    }
}
