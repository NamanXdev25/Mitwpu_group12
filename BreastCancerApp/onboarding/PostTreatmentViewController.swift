import UIKit

class PostTreatmentViewController: UIViewController {
    @IBOutlet var progressBar: ProgressBarView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!

    private var completionDate: Date = .init()
    private var selectedMaintenanceTherapy: String?

    private let maintenanceOptions = OnboardingDataSource.maintenanceTherapyOptions
    private let dateCellID = "OnboardingDatePickerCell"
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
        collectionView.register(
            UINib(nibName: dateCellID, bundle: nil),
            forCellWithReuseIdentifier: dateCellID
        )
        collectionView.register(
            UINib(nibName: selectionCellID, bundle: nil),
            forCellWithReuseIdentifier: selectionCellID
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = makeLayout()
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] _, _ in
            guard let self else { return Self.makeSection(topInset: 0) }
            let collectionHeight = self.collectionView.bounds.height
            let itemHeight: CGFloat = 90
            let spacing: CGFloat = 16
            let totalContentHeight = (itemHeight * 2) + spacing
            let topInset = max(0, (collectionHeight - totalContentHeight) / 2)
            return Self.makeSection(topInset: topInset)
        }
    }

    private static func makeSection(topInset: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(90)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: topInset, leading: 0, bottom: 8, trailing: 0)
        return section
    }

    private func updateNextButton() {
        let isValid = selectedMaintenanceTherapy != nil
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }

    @IBAction func nextButtonTapped(_: UIButton) {
        OnboardingData.shared.treatmentCompletionDate = completionDate
        OnboardingData.shared.maintenanceTherapy = selectedMaintenanceTherapy
        performSegue(withIdentifier: "showFocus", sender: nil)
    }

    @IBAction func skipButtonTapped(_: UIButton) {
        performSegue(withIdentifier: "showFocus", sender: nil)
    }
}

extension PostTreatmentViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        2
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: dateCellID, for: indexPath
            ) as? OnboardingDatePickerCell else {
                fatalError("Expected OnboardingDatePickerCell for reuse identifier '\(dateCellID)' at \(indexPath)")
            }
            cell.configure(title: "When did you complete treatment?", fieldName: "Completion Date", maximumDate: Date())
            cell.onDateChanged = { [weak self] date in self?.completionDate = date }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: selectionCellID, for: indexPath
            ) as? OnboardingSelectionPickerCell else {
                fatalError("Expected OnboardingSelectionPickerCell for reuse identifier '\(selectionCellID)' at \(indexPath)")
            }
            cell.configure(
                title: "Are you on maintenance therapy?",
                fieldName: "Maintenance Therapy",
                options: maintenanceOptions,
                selectedValue: selectedMaintenanceTherapy
            )
            cell.onOptionSelected = { [weak self] option in
                guard let self else { return }
                self.selectedMaintenanceTherapy = option
                self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
                self.updateNextButton()
            }
            return cell
        }
    }
}

extension PostTreatmentViewController: UICollectionViewDelegate {}
