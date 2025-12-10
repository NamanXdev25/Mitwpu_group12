// TestHistoryViewController.swift
import UIKit

class TestHistoryViewController: UIViewController,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    private var records: [TestRecord] = []
    private var expandedIndexSet = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        let titleLabel = UILabel()
        titleLabel.text = "Test History"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // Ensure a single-column flow layout and disable automatic estimated sizing
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .vertical
            flow.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
            flow.minimumInteritemSpacing = 0
            flow.minimumLineSpacing = 12
            flow.estimatedItemSize = .zero
            collectionView.collectionViewLayout.invalidateLayout()
        }

        let nib = UINib(nibName: "TestRecordCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "TestRecordCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true

        records = Persistence.load()
        collectionView.reloadData()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(testRecordAdded(_:)),
                                               name: .testRecordAdded,
                                               object: nil)
    }

    @objc private func testRecordAdded(_ n: Notification) {
        records = Persistence.load()
        collectionView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .testRecordAdded, object: nil)
    }

    func appendRecord(_ record: TestRecord) {
        records.insert(record, at: 0)
        try? Persistence.save(records)
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return records.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestRecordCell", for: indexPath) as? TestRecordCell else {
            fatalError("TestRecordCell not registered")
        }

        let rec = records[indexPath.item]
        let isExpanded = expandedIndexSet.contains(indexPath.item)
        let details = isExpanded ? rec.observations : nil
        cell.configureDate(rec.date, details: details)

        cell.onChevronTap = { [weak self, weak collectionView, weak cell] in
            guard let self = self, let cv = collectionView, let cell = cell, let realIndex = cv.indexPath(for: cell) else {
                print("⚠️ chevronTap: could not resolve indexPath")
                return
            }

            if self.expandedIndexSet.contains(realIndex.item) {
                self.expandedIndexSet.remove(realIndex.item)
            } else {
                self.expandedIndexSet.insert(realIndex.item)
            }

            DispatchQueue.main.async {
                cv.performBatchUpdates(nil) { _ in
                    cv.reloadItems(at: [realIndex])
                }
            }
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use the collection width minus section insets (left+right = 32)
        let width = collectionView.bounds.width - 32
        let collapsedHeight: CGFloat = 84    // smaller gap
        if expandedIndexSet.contains(indexPath.item) {
            let detailCount = CGFloat(records[indexPath.item].observations.count)
            let detailRow: CGFloat = 44.0
            let total = 48 /*date row*/ + detailCount * detailRow + 24 /*padding*/
            return CGSize(width: width, height: max(collapsedHeight, total))
        } else {
            return CGSize(width: width, height: collapsedHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.item) { expandedIndexSet.remove(indexPath.item) }
        else { expandedIndexSet.insert(indexPath.item) }
        collectionView.performBatchUpdates(nil) { _ in
            collectionView.reloadItems(at: [indexPath])
        }
    }
}
