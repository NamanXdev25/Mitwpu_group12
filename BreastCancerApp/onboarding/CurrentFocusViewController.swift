import UIKit

class CurrentFocusViewController: UIViewController {
    @IBOutlet var progressBar: ProgressBarView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!

    private var selectedFocusIndices = Set<Int>()
    private let focusOptions = OnboardingDataSource.currentFocusOptions
    private let focusCellID = "InterestsCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 7, totalSteps: 9, animated: true)
    }

    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButton()
    }

    private func setupCollectionView() {
        collectionView.register(
            UINib(nibName: focusCellID, bundle: nil),
            forCellWithReuseIdentifier: focusCellID
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = makeLayout()
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let spacing: CGFloat = 12
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalWidth(0.4)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: spacing / 2,
                bottom: 0,
                trailing: spacing / 2
            )
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.4)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item, item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 16 + spacing / 2,
                bottom: 16,
                trailing: 16 + spacing / 2
            )
            return section
        }
    }

    private func updateNextButton() {
        let isValid = !selectedFocusIndices.isEmpty
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }

    @IBAction func nextButtonTapped(_: UIButton) {
        OnboardingData.shared.currentFocus = selectedFocusIndices.map { focusOptions[$0].title }
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }

    @IBAction func skipButtonTapped(_: UIButton) {
        performSegue(withIdentifier: "showHobbies", sender: nil)
    }
}

extension CurrentFocusViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        focusOptions.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: focusCellID, for: indexPath
        ) as? InterestsCell else {
            fatalError("Expected InterestsCell for reuse identifier '\(focusCellID)' at \(indexPath)")
        }
        let option = focusOptions[indexPath.item]
        let isSelected = selectedFocusIndices.contains(indexPath.item)
        cell.configure(with: option.title, icon: option.icon, isSelected: isSelected)
        return cell
    }
}

extension CurrentFocusViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if selectedFocusIndices.contains(indexPath.item) {
            selectedFocusIndices.remove(indexPath.item)
        } else {
            selectedFocusIndices.insert(indexPath.item)
        }
        collectionView.reloadItems(at: [indexPath])
        updateNextButton()
    }
}
