import UIKit

class OnboardingMindfulnessViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var mindfulnessImage: UIView!

    private let features = OnboardingFeature.mindfulnessFeatures

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let progressBarView = progressBar as? ProgressBarView {
            progressBarView.setProgress(currentStep: 1, totalSteps: 5, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mask = CAGradientLayer()
        mask.frame = mindfulnessImage.bounds
        mask.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        mask.locations = [0.0, 0.45, 0.95]
        mindfulnessImage.layer.mask = mask
    }

    private func setupCollectionView() {
        let nib = UINib(nibName: "OnboardingFeatureCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "OnboardingFeatureCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 237, height: 50)
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    private func setupUI() {
        if let progressBarView = progressBar as? ProgressBarView {
            progressBarView.setProgress(0, animated: false)
        }
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showHealth", sender: nil)
    }
}

extension OnboardingMindfulnessViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        features.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingFeatureCell", for: indexPath) as? OnboardingFeatureCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: features[indexPath.item])
        return cell
    }
}

extension OnboardingMindfulnessViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension OnboardingMindfulnessViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width - 32, height: 50)
    }
}
