import UIKit

protocol ObservationsCollector {
    func collectObservations() -> [ObservationItem]
}

final class ObservationsViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var doneBarButton: UIBarButtonItem!

    private var shouldShowDisclaimer = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        collectionView.setCollectionViewLayout(layout, animated: false)

        let observationsNib = UINib(nibName: "ObservationsContainerCell", bundle: nil)
        collectionView.register(observationsNib, forCellWithReuseIdentifier: "ObservationsContainerCell")

        let disclaimerNib = UINib(nibName: "ObservationDisclaimerCell", bundle: nil)
        collectionView.register(disclaimerNib, forCellWithReuseIdentifier: "ObservationDisclaimerCell")

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBAction private func doneBarButtonTapped(_: UIBarButtonItem) {
        doneTapped()
    }

    private func doneTapped() {
        var observations: [ObservationItem] = []

        if let cell = collectionView.visibleCells.first(where: { $0 is ObservationsContainerCell }) as? ObservationsCollector {
            observations = cell.collectObservations()
        }

        if observations.isEmpty {
            observations = [
                ObservationItem(title: "Lumps/Thickening", value: "No"),
                ObservationItem(title: "Size/Shape changes", value: "No"),
                ObservationItem(title: "Skin changes", value: "None"),
                ObservationItem(title: "Nipple changes", value: "None"),
                ObservationItem(title: "Pain/Tenderness", value: "None"),
            ]
        }

        let new = TestRecord(id: UUID(), date: Date(), observations: observations)
        var all = Persistence.load()
        all.insert(new, at: 0)
        try? Persistence.save(all)

        NotificationCenter.default.post(name: .testRecordAdded, object: nil)
        navigationController?.popViewController(animated: true)
    }
}

extension ObservationsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        shouldShowDisclaimer ? 2 : 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ObservationsContainerCell",
                for: indexPath
            ) as? ObservationsContainerCell else {
                fatalError("Expected ObservationsContainerCell for reuse identifier 'ObservationsContainerCell' at \(indexPath)")
            }

            cell.onSelectionChanged = { [weak self] shouldShow in
                guard let self else { return }

                if self.shouldShowDisclaimer != shouldShow {
                    self.shouldShowDisclaimer = shouldShow
                    self.collectionView.reloadData()
                }
            }

            return cell
        }

        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "ObservationDisclaimerCell",
            for: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        let horizontalInsets = layout.sectionInset.left + layout.sectionInset.right
        let width = collectionView.bounds.width - horizontalInsets

        if indexPath.item == 0 {
            return CGSize(width: width, height: 360)
        } else {
            return CGSize(width: width, height: 134)
        }
    }
}
