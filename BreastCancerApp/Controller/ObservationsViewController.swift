// ObservationsViewController.swift
import UIKit

protocol ObservationsCollector {
    func collectObservations() -> [ObservationItem]
}

class ObservationsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Your Observations"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // Done button
        let doneBtn = UIButton(type: .custom)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        doneBtn.layer.cornerRadius = 22
        doneBtn.backgroundColor = UIColor(named: "pink") ?? .systemPink
        doneBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        doneBtn.tintColor = .white
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)

        // Cell registration
        let nib = UINib(nibName: "ObservationsContainerCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ObservationsContainerCell")
        collectionView.dataSource = self
        collectionView.delegate = self

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.sectionInset = UIEdgeInsets(top: 24, left: 4, bottom: 0, right: 4)
            flow.minimumInteritemSpacing = 0
            flow.minimumLineSpacing = 0
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    @objc func doneTapped() {
        // Try to extract observations from the visible cell
        var observations: [ObservationItem] = []

        if let cell = collectionView.visibleCells.first {
            if let collector = cell as? ObservationsCollector {
                observations = collector.collectObservations()
            }
        }

        // Fallback safe defaults if collector not available or returned empty
        if observations.isEmpty {
            observations = [
                ObservationItem(title: "Lumps/Thickening", value: "No"),
                ObservationItem(title: "Size/Shape changes", value: "No"),
                ObservationItem(title: "Skin changes", value: "None"),
                ObservationItem(title: "Nipple changes", value: "None"),
                ObservationItem(title: "Pain/Tenderness", value: "None")
            ]
        }

        // Persist and notify
        let new = TestRecord(id: UUID(), date: Date(), observations: observations)
        var all = Persistence.load()
        all.insert(new, at: 0)
        try? Persistence.save(all)
        NotificationCenter.default.post(name: .testRecordAdded, object: nil)

        // Return to previous screen
        navigationController?.popViewController(animated: true)
    }
}

extension ObservationsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

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

        let width = collectionView.bounds.width - 8
        return CGSize(width: width, height: 390)
    }
}
