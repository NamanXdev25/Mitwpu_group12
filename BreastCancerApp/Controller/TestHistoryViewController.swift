import UIKit

final class TestHistoryViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Data
    private var records: [TestRecord] = []
    private var expandedIndexSet = Set<Int>()

    // Pink background (centralized).
    private var bgColor: UIColor {
        UIColor(named: "BGPink") ?? UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation title
        let lbl = UILabel()
        lbl.text = "Log History"
        lbl.font = .systemFont(ofSize: 17, weight: .semibold)
        lbl.textAlignment = .center
        navigationItem.titleView = lbl

        // Collection setup
        collectionView.collectionViewLayout = generateLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true

        // Background
        view.backgroundColor = bgColor
        collectionView.backgroundColor = bgColor

        // Register cell
        collectionView.register(UINib(nibName: "TestRecordCell", bundle: nil),
                                forCellWithReuseIdentifier: "TestRecordCell")

        // Load and refresh
        records = Persistence.load()
        updateEmptyState()
        collectionView.reloadData()

        // Listen for new records
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(testRecordAdded),
                                               name: .testRecordAdded,
                                               object: nil)
    }

    @objc private func testRecordAdded(_ n: Notification) {
        records = Persistence.load()
        updateEmptyState()
        collectionView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Add a record to the top
    func appendRecord(_ record: TestRecord) {
        records.insert(record, at: 0)
        try? Persistence.save(records)
        updateEmptyState()
        collectionView.reloadData()
    }

    // MARK: - Empty State
    private func updateEmptyState() {
        guard records.isEmpty else {
            collectionView.backgroundView = nil
            collectionView.backgroundColor = bgColor
            return
        }

        let lbl = UILabel()
        lbl.text = "Your log records will appear here."
        lbl.font = .systemFont(ofSize: 16)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView(frame: collectionView.bounds)
        container.addSubview(lbl)

        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            lbl.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            lbl.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24)
        ])

        collectionView.backgroundView = container
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { records.count }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TestRecordCell",
                for: indexPath) as? TestRecordCell else {
            fatalError("TestRecordCell not registered")
        }

        // Transparent background for list appearance
        cell.backgroundConfiguration = .clear()
        cell.contentView.backgroundColor = .clear

        let rec = records[indexPath.item]
        let isExpanded = expandedIndexSet.contains(indexPath.item)

        // Configure cell
        cell.configureDate(rec.date,
                           details: isExpanded ? rec.observations : nil)

        // Toggle expansion via chevron
        cell.onChevronTap = { [weak self, weak cell] in
            guard
                let self = self,
                let index = self.collectionView.indexPath(for: cell!) else { return }

            self.toggleExpansion(at: index)
        }

        // Delete request from cell
        cell.onRequestDelete = { [weak self] in
            self?.confirmDelete(at: indexPath) { _ in }
        }

        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        toggleExpansion(at: indexPath)
    }

    // MARK: - Expansion Logic
    private func toggleExpansion(at indexPath: IndexPath) {
        expandedIndexSet.formSymmetricDifference([indexPath.item])
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [indexPath])
        }
    }

    // MARK: - Layout + Swipe
    private func generateLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = .clear
        config.headerMode = .none

        // Swipe-to-delete
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }

            let delete = UIContextualAction(style: .destructive, title: "Delete") {
                _, _, completion in
                self.confirmDelete(at: indexPath, completion: completion)
            }

            delete.image = UIImage(systemName: "trash.fill")
            delete.backgroundColor = .systemRed

            let swipe = UISwipeActionsConfiguration(actions: [delete])
            swipe.performsFirstActionWithFullSwipe = false
            return swipe
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    // MARK: - Delete
    func confirmDelete(at indexPath: IndexPath,
                       completion: @escaping (Bool) -> Void) {

        guard indexPath.item < records.count else {
            completion(false)
            return
        }

        let alert = UIAlertController(title: "Delete Record?",
                                      message: "Are you sure you want to delete this record?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { completion(false); return }

            // Remove and save
            self.records.remove(at: indexPath.item)
            try? Persistence.save(self.records)

            // Fix expanded indexes
            self.expandedIndexSet = Set(self.expandedIndexSet
                .compactMap { $0 == indexPath.item ? nil : ($0 > indexPath.item ? $0 - 1 : $0) })

            // Animate delete
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }, completion: { _ in
                self.updateEmptyState()
                self.collectionView.reloadData()
                completion(true)
            })
        })

        present(alert, animated: true)
    }
}
