import UIKit

class JourneyViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    private var diagnosisModel = DiagnosisModel()
    private var waitModel = WaitModel()
    private var treatmentModel = TreatmentModel()

    private var cellHeights: [Int: CGFloat] = [
        0: 200,
        1: 540,
        2: 140
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Journey"
    }

    private func setupCollectionView() {
        let diagnosisNib = UINib(nibName: "DiagnosisCell", bundle: nil)
        collectionView.register(diagnosisNib, forCellWithReuseIdentifier: "DiagnosisCell")

        let waitNib = UINib(nibName: "WaitCell", bundle: nil)
        collectionView.register(waitNib, forCellWithReuseIdentifier: "WaitCell")

        let treatmentNib = UINib(nibName: "TreatmentCell", bundle: nil)
        collectionView.register(treatmentNib, forCellWithReuseIdentifier: "TreatmentCell")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        }
    }

    // MARK: - Height Update Helper
    private func updateHeight(for index: Int, height: CGFloat) {
        guard cellHeights[index] != height else { return }
        cellHeights[index] = height
        UIView.performWithoutAnimation {
            self.collectionView.performBatchUpdates(nil)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension JourneyViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiagnosisCell", for: indexPath) as? DiagnosisCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: diagnosisModel)
            cell.onDateSelected = { [weak self] date in
                self?.diagnosisModel.diagnosisDate = date
            }
            cell.onSaveButtonTapped = { [weak self] in
                self?.diagnosisModel.status = "Completed"
            }
            cell.onCellHeightChanged = { [weak self] in
                guard let self = self else { return }
                let height = cell.getCellHeight()
                self.updateHeight(for: 0, height: height)
            }
            return cell

        } else if indexPath.item == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaitCell", for: indexPath) as? WaitCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: waitModel)
            cell.onSaveButtonTapped = { [weak self] in
                self?.waitModel.status = "Completed"
            }
            cell.onCellHeightChanged = { [weak self] in
                guard let self = self else { return }
                let height = cell.getCellHeight()
                self.updateHeight(for: 1, height: height)
            }
            return cell

        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TreatmentCell", for: indexPath) as? TreatmentCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: treatmentModel)
            cell.onSaveButtonTapped = { [weak self] phase, index in
                guard let self = self else { return }
                self.treatmentModel.phases.append(phase)
                print("💾 Treatment phase \(index + 1) saved")
            }
            cell.onCellHeightChanged = { [weak self] in
                guard let self = self else { return }
                let height = cell.getCellHeight()
                self.updateHeight(for: 2, height: height)
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JourneyViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = view.bounds.width
        let padding: CGFloat = 32
        let cellWidth = totalWidth - padding
        let height = cellHeights[indexPath.item] ?? 200
        return CGSize(width: cellWidth, height: height)
    }
}
