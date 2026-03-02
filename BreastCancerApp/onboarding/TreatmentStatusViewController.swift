import UIKit

class TreatmentStatusViewController: UIViewController {
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nextButton: UIButton!

    private var treatmentOptions: [String] = []
    private var selectedIndex: Int? {
        didSet { updateNextButtonState() }
    }
    private var optionViews: [TreatmentOptionView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTreatmentOptions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 2, totalSteps: 5, animated: true)
    }

    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButtonState()
    }

    private func loadTreatmentOptions() {
        treatmentOptions = OnboardingDataSource.treatmentOptions

        for (index, option) in treatmentOptions.enumerated() {
            let optionView = TreatmentOptionView()
            optionView.title = option
            optionView.translatesAutoresizingMaskIntoConstraints = false
            optionView.heightAnchor.constraint(equalToConstant: 64).isActive = true
            optionView.onTap = { [weak self] in self?.handleOptionTapped(at: index) }
            stackView.addArrangedSubview(optionView)
            optionViews.append(optionView)
        }
    }

    private func handleOptionTapped(at index: Int) {
        optionViews.forEach { $0.isSelectedOption = false }
        optionViews[index].isSelectedOption = true
        selectedIndex = index
        OnboardingData.shared.treatmentStatus = treatmentOptions[index]
    }

    private func updateNextButtonState() {
        nextButton.isEnabled = selectedIndex != nil
        nextButton.alpha = selectedIndex != nil ? 1.0 : 0.5
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let index = selectedIndex else { return }

        let identifier: String
        switch index {
        case 0:
            identifier = "showJourneyDetails"
        case 1:
            identifier = "showPostTreatment"
        default:
            identifier = "showFocus"
        }

        performSegue(withIdentifier: identifier, sender: nil)
    }
}
