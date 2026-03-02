import UIKit

class JourneyDetailsViewController: UIViewController {

    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    private var diagnosisDate: Date = Date()
    private var selectedTreatmentPhase: String?

    private let treatmentPhaseOptions = OnboardingDataSource.treatmentPhases
    private let dateCellID      = "OnboardingDatePickerCell"
    private let selectionCellID = "OnboardingSelectionPickerCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 6, totalSteps: 9, animated: true)
    }

    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButton()
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: dateCellID, bundle: nil),
                                forCellWithReuseIdentifier: dateCellID)
        collectionView.register(UINib(nibName: selectionCellID, bundle: nil),
                                forCellWithReuseIdentifier: selectionCellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = makeLayout()
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .estimated(90))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .estimated(90))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 24
            section.contentInsets = NSDirectionalEdgeInsets(top: 32, leading: 0, bottom: 0, trailing: 0)
            return section
        }
    }

    private func updateNextButton() {
        let isValid = selectedTreatmentPhase != nil
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        OnboardingData.shared.diagnosisDate = diagnosisDate
        OnboardingData.shared.currentTreatmentPhase = selectedTreatmentPhase
        performSegue(withIdentifier: "showFocus", sender: nil)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showFocus", sender: nil)
    }
}

extension JourneyDetailsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: dateCellID, for: indexPath
            ) as! OnboardingDatePickerCell
            cell.configure(title: "When were you diagnosed?", fieldName: "Diagnosis Date", maximumDate: Date())
            cell.onDateChanged = { [weak self] date in self?.diagnosisDate = date }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: selectionCellID, for: indexPath
            ) as! OnboardingSelectionPickerCell
            cell.configure(title: "What treatment are you currently undergoing?",
                           fieldName: "Treatment Phase",
                           options: treatmentPhaseOptions,
                           selectedValue: selectedTreatmentPhase)
            cell.onOptionSelected = { [weak self] phase in
                guard let self else { return }
                self.selectedTreatmentPhase = phase
                self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
                self.updateNextButton()
            }
            return cell
        }
    }
}

extension JourneyDetailsViewController: UICollectionViewDelegate {}
