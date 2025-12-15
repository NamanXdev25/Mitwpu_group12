import UIKit

class TestHistoryViewController: UIViewController,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    private var records: [TestRecord] = []
    private var expandedIndexSet = Set<Int>()

    private var bgColor: UIColor {
        return UIColor(named: "BGPink") ?? UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        let titleLabel = UILabel()
        titleLabel.text = "Test History"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // layout + appearance
        collectionView.collectionViewLayout = generateLayout()
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self

        // FORCE pink background everywhere (collection + view)
        view.backgroundColor = bgColor
        collectionView.backgroundColor = bgColor
        collectionView.backgroundView = nil

        // Register nib (keep reuse identifier "TestRecordCell")
        let nib = UINib(nibName: "TestRecordCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "TestRecordCell")

        records = Persistence.load()
        updateEmptyState()
        collectionView.reloadData()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(testRecordAdded(_:)),
                                               name: .testRecordAdded,
                                               object: nil)
    }

    @objc private func testRecordAdded(_ n: Notification) {
        records = Persistence.load()
        updateEmptyState()
        collectionView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .testRecordAdded, object: nil)
    }

    func appendRecord(_ record: TestRecord) {
        records.insert(record, at: 0)
        try? Persistence.save(records)
        updateEmptyState()
        collectionView.reloadData()
    }

    // MARK: - Empty State
    private func updateEmptyState() {
        // always keep pink background; only show placeholder when empty
        if records.isEmpty {
            let lbl = UILabel()
            lbl.text = "Your test records will appear here."
            lbl.font = .systemFont(ofSize: 16, weight: .regular)
            lbl.textAlignment = .center
            lbl.numberOfLines = 0
            lbl.translatesAutoresizingMaskIntoConstraints = false

            let container = UIView(frame: collectionView.bounds)
            container.backgroundColor = .clear
            container.addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                lbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                lbl.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
                lbl.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24)
            ])
            collectionView.backgroundView = container
            collectionView.backgroundColor = bgColor
        } else {
            collectionView.backgroundView = nil
            collectionView.backgroundColor = bgColor
        }
        view.backgroundColor = bgColor
    }

    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return records.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestRecordCell", for: indexPath) as? TestRecordCell else {
            fatalError("TestRecordCell not registered")
        }

        // enforce transparency for list-layout cells
        cell.backgroundConfiguration = .clear()
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear

        let rec = records[indexPath.item]
        let isExpanded = expandedIndexSet.contains(indexPath.item)
        let details = isExpanded ? rec.observations : nil
        cell.configureDate(rec.date, details: details)

        cell.onChevronTap = { [weak self, weak collectionView, weak cell] in
            guard let self = self, let cv = collectionView, let cell = cell, let realIndex = cv.indexPath(for: cell) else { return }
            if self.expandedIndexSet.contains(realIndex.item) { self.expandedIndexSet.remove(realIndex.item) }
            else { self.expandedIndexSet.insert(realIndex.item) }
            DispatchQueue.main.async {
                cv.performBatchUpdates(nil) { _ in cv.reloadItems(at: [realIndex]) }
            }
        }

        cell.onRequestDelete = { [weak self] in
            guard let self = self else { return }
            self.confirmDelete(at: indexPath) { _ in }
        }

        return cell
    }

    // MARK: - Delegate (expand on select)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.item) { expandedIndexSet.remove(indexPath.item) }
        else { expandedIndexSet.insert(indexPath.item) }
        collectionView.performBatchUpdates(nil) { _ in collectionView.reloadItems(at: [indexPath]) }
    }

    // MARK: - Layout + Swipe Actions
    func generateLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.headerMode = .none

        // IMPORTANT: make the list background transparent so collectionView bg shows
        config.backgroundColor = .clear

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                self.confirmDelete(at: indexPath, completion: completion)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = .systemRed
            let s = UISwipeActionsConfiguration(actions: [deleteAction])
            s.performsFirstActionWithFullSwipe = false
            return s
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    // MARK: - Delete Confirm
    func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard indexPath.item < records.count else { completion(false); return }
        let alert = UIAlertController(title: "Delete Record?",
                                      message: "Are you sure you want to delete this record?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion(false) })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { completion(false); return }
            self.records.remove(at: indexPath.item)
            try? Persistence.save(self.records)
            self.expandedIndexSet = Set(self.expandedIndexSet
                .filter { $0 != indexPath.item }
                .map { $0 > indexPath.item ? $0 - 1 : $0 })
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [indexPath])
                }, completion: { _ in
                    self.updateEmptyState()
                    self.collectionView.reloadData()
                    completion(true)
                })
            }
        })
        present(alert, animated: true)
    }
}
