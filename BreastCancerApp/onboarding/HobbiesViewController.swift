import UIKit

class HobbiesViewController: UIViewController {
    @IBOutlet var progressBar: ProgressBarView!
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!

    private let hobbies = OnboardingDataSource.hobbies
    private var selectedHobbies: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressBar.setProgress(currentStep: 8, totalSteps: 9, animated: true)
    }

    private func setupUI() {
        progressBar.setProgress(0, animated: false)
        navigationItem.backButtonTitle = ""
        updateNextButtonState()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear

        let nib = UINib(nibName: "HobbyCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "HobbyCell")

        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collectionView.collectionViewLayout = layout
    }

    private func updateNextButtonState() {
        let isValid = !selectedHobbies.isEmpty
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }

    private func saveData() {
        OnboardingData.shared.selectedHobbies = Array(selectedHobbies)
    }

    @IBAction func skipButtonTapped(_: UIButton) {
        performSegue(withIdentifier: "showCompletion", sender: nil)
    }

    @IBAction func nextButtonTapped(_: UIButton) {
        saveData()
        performSegue(withIdentifier: "showCompletion", sender: nil)
    }
}

extension HobbiesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return hobbies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyCell", for: indexPath) as? HobbyCell else {
            fatalError("Expected HobbyCell for reuse identifier 'HobbyCell' at \(indexPath)")
        }

        let hobby = hobbies[indexPath.item]
        cell.configure(with: hobby, isSelected: selectedHobbies.contains(hobby))

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hobby = hobbies[indexPath.item]

        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else {
            selectedHobbies.insert(hobby)
        }

        collectionView.reloadItems(at: [indexPath])
        updateNextButtonState()
    }
}
