import UIKit

protocol ObservationsCollector {
    func collectObservations() -> [ObservationItem]
}

class ObservationsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ObservationsContainerCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ObservationsContainerCell")

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        doneTapped()
    }

    @objc func doneTapped() {
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "ObservationsContainerCell",
            for: indexPath
        ) as! ObservationsContainerCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

       
        let width = collectionView.frame.width - 40
        return CGSize(width: width, height: 360)
    }
}
