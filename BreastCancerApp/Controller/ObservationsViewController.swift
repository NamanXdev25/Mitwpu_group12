//
// ObservationsViewController.swift
//

import UIKit

protocol ObservationsCollector {
    func collectObservations() -> [ObservationItem]
}

class ObservationsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // ---------- NEW: outlet for storyboard bar button ----------
    @IBOutlet weak var doneBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ---------- Transparent Navigation Bar ----------
        if let navBar = navigationController?.navigationBar {
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = .clear
                appearance.backgroundEffect = nil
                appearance.shadowColor = .clear

                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = appearance
                navBar.compactAppearance = appearance
            } else {
                navBar.setBackgroundImage(UIImage(), for: .default)
                navBar.shadowImage = UIImage()
                navBar.isTranslucent = true
                navBar.backgroundColor = .clear
            }

            navBar.isTranslucent = true
        }

        // ---------- Title ----------
        let titleLabel = UILabel()
        titleLabel.text = "Your Observations"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // ---------- Background ----------
        let pagePink = UIColor(named: "BGPink") ??
            UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1.0)
        view.backgroundColor = pagePink

        // ---------- Collection View ----------
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.alwaysBounceVertical = true

        let nib = UINib(nibName: "ObservationsContainerCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ObservationsContainerCell")

        collectionView.dataSource = self
        collectionView.delegate = self

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.sectionInset = UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20)
            flow.minimumLineSpacing = 0
            flow.minimumInteritemSpacing = 0
            flow.invalidateLayout()
        }
    }

    // ---------- IBAction wired from storyboard ----------
    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        // keep same behavior; reuse the existing function
        doneTapped()
    }

    // ---------- Done Action (unchanged) ----------
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

// ---------- Collection ----------
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

        let width = collectionView.bounds.width - 40
        return CGSize(width: width, height: 360)
    }
}
