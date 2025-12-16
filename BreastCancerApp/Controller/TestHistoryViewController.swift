import UIKit

final class TestHistoryViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Data
    private var records: [TestRecord] = []
    private var expandedIndexSet = Set<Int>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        loadData()
        observeNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Log History"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }

    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(
            UINib(nibName: "TestRecordCell", bundle: nil),
            forCellWithReuseIdentifier: "TestRecordCell"
        )
    }

    private func loadData() {
        records = Persistence.load()
        updateEmptyState()
        collectionView.reloadData()
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTestRecordAdded),
            name: .testRecordAdded,
            object: nil
        )
    }

    @objc private func handleTestRecordAdded(_ notification: Notification) {
        records = Persistence.load()
        updateEmptyState()
        collectionView.reloadData()
    }

    // MARK: - Public Methods
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
            return
        }

        let emptyLabel = createEmptyStateLabel()
        let container = UIView(frame: collectionView.bounds)
        container.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24)
        ])

        collectionView.backgroundView = container
    }

    private func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.text = "Your log records will appear here."
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        records.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TestRecordCell",
            for: indexPath
        ) as? TestRecordCell else {
            fatalError("TestRecordCell not registered")
        }

        configureCell(cell, at: indexPath)
        return cell
    }

    private func configureCell(_ cell: TestRecordCell, at indexPath: IndexPath) {
        cell.backgroundConfiguration = .clear()
        cell.contentView.backgroundColor = .clear

        let record = records[indexPath.item]
        let isExpanded = expandedIndexSet.contains(indexPath.item)

        cell.configure(
            date: record.date,
            details: isExpanded ? record.observations : nil
        )

        cell.onChevronTap = { [weak self] in
            self?.toggleExpansion(at: indexPath)
        }

        cell.onRequestDelete = { [weak self] in
            self?.confirmDelete(at: indexPath) { _ in }
        }
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleExpansion(at: indexPath)
    }

    // MARK: - Expansion Logic
    private func toggleExpansion(at indexPath: IndexPath) {
        expandedIndexSet.formSymmetricDifference([indexPath.item])
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [indexPath])
        }
    }

    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = true
        config.backgroundColor = .clear
        config.headerMode = .none
        
        
        config.itemSeparatorHandler = { [weak self] indexPath, sectionSeparatorConfiguration in
            var configuration = sectionSeparatorConfiguration
            
         
            if indexPath.item == 0 {
                configuration.topSeparatorVisibility = .hidden
            }
            
            return configuration
        }
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            self?.createSwipeActions(for: indexPath)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    private func createSwipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            self?.confirmDelete(at: indexPath, completion: completion)
        }

        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    // MARK: - Delete
    func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard indexPath.item < records.count else {
            completion(false)
            return
        }

        let alert = createDeleteAlert(for: indexPath, completion: completion)
        present(alert, animated: true)
    }

    private func createDeleteAlert(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "Delete Record?",
            message: "Are you sure you want to delete this record?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(at: indexPath, completion: completion)
        })

        return alert
    }

    private func performDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        records.remove(at: indexPath.item)
        try? Persistence.save(records)

        updateExpandedIndices(after: indexPath.item)

        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        }, completion: { [weak self] _ in
            self?.updateEmptyState()
            self?.collectionView.reloadData()
            completion(true)
        })
    }

    private func updateExpandedIndices(after deletedIndex: Int) {
        expandedIndexSet = Set(expandedIndexSet.compactMap { index in
            if index == deletedIndex {
                return nil
            } else if index > deletedIndex {
                return index - 1
            } else {
                return index
            }
        })
    }
}
