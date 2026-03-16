import UIKit

protocol ObservationsCollector {
    func collectObservations() -> [ObservationItem]
}

final class ObservationsViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var doneBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.setCollectionViewLayout(layout, animated: false)

        let nib = UINib(nibName: "ObservationsContainerCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ObservationsContainerCell")

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBAction private func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        doneTapped()
    }

    private func doneTapped() {
        var observations: [ObservationItem] = []

        if let cell = collectionView.visibleCells.first,
           let collector = cell as? ObservationsCollector {
            observations = collector.collectObservations()
        }

        if observations.isEmpty {
            observations = [
                ObservationItem(title: "Lumps/Thickening", value: "No"),
                ObservationItem(title: "Size/Shape changes", value: "No"),
                ObservationItem(title: "Skin changes", value: "None"),
                ObservationItem(title: "Nipple changes", value: "None"),
                ObservationItem(title: "Pain/Tenderness", value: "None")
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
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        collectionView.dequeueReusableCell(
            withReuseIdentifier: "ObservationsContainerCell",
            for: indexPath
        ) as! ObservationsContainerCell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let horizontalInsets = layout.sectionInset.left + layout.sectionInset.right
        let width = collectionView.bounds.width - horizontalInsets

        return CGSize(width: width, height: 360)
    }
}
