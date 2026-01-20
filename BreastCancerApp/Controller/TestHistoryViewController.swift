import UIKit

final class TestHistoryViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Data
    private var records: [TestRecord] = []
    private var filteredRecords: [TestRecord] = []
    private var expandedIndexSet = Set<Int>()

    private var availableYears: [Int] = []
    private var selectedYear: Int?

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

        // Year filter cell (XIB)
        collectionView.register(
            UINib(nibName: "YearFilterCell", bundle: nil),
            forCellWithReuseIdentifier: YearFilterCell.reuseIdentifier
        )

        // Record cell
        collectionView.register(
            UINib(nibName: "TestRecordCell", bundle: nil),
            forCellWithReuseIdentifier: "TestRecordCell"
        )
    }

    private func loadData() {
        records = Persistence.load()
        setupAvailableYears()
        filterRecords(for: selectedYear)
        updateEmptyState()
        collectionView.reloadData()
    }

    private func setupAvailableYears() {
        let calendar = Calendar.current
        let years = records.map { calendar.component(.year, from: $0.date) }
        availableYears = Array(Set(years)).sorted()
        selectedYear = availableYears.last
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
        setupAvailableYears()
        filterRecords(for: selectedYear)
        updateEmptyState()
        collectionView.reloadData()
    }

    // MARK: - Year Filtering
    @objc private func didTapYearFilter() {
        let alert = UIAlertController(title: "Select Year", message: nil, preferredStyle: .actionSheet)

        availableYears.forEach { year in
            alert.addAction(UIAlertAction(title: "\(year)", style: .default) { [weak self] _ in
                self?.selectedYear = year
                self?.filterRecords(for: year)
                self?.expandedIndexSet.removeAll()
                self?.collectionView.reloadData()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func filterRecords(for year: Int?) {
        guard let year else {
            filteredRecords = records
            return
        }

        let calendar = Calendar.current
        filteredRecords = records.filter {
            calendar.component(.year, from: $0.date) == year
        }
    }

    // MARK: - Empty State
    private func updateEmptyState() {
        guard !filteredRecords.isEmpty else {
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
            return
        }

        collectionView.backgroundView = nil
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 1 : filteredRecords.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        // Section 0 → Year filter cell
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: YearFilterCell.reuseIdentifier,
                for: indexPath
            ) as! YearFilterCell

            cell.yearButton.setTitle("\(selectedYear ?? 0)", for: .normal)
            cell.yearButton.addTarget(self, action: #selector(didTapYearFilter), for: .touchUpInside)
            return cell
        }

        // Section 1 → Record cells
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

        let record = filteredRecords[indexPath.item]
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
        if indexPath.section == 1 {
            toggleExpansion(at: indexPath)
        }
    }

    // MARK: - Expansion Logic
    private func toggleExpansion(at indexPath: IndexPath) {
        expandedIndexSet.formSymmetricDifference([indexPath.item])
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [indexPath])
        }
    }

    // MARK: - Layout (native dividers, top divider removed for year cell)
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = true
        config.backgroundColor = .clear
        config.headerMode = .none

       
        config.itemSeparatorHandler = { indexPath, separator in
            var separator = separator
            if indexPath.section == 0 && indexPath.item == 0 {
                separator.topSeparatorVisibility = .hidden
            }
            return separator
        }

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard indexPath.section == 1 else { return nil }
            return self?.createSwipeActions(for: indexPath)
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

        present(alert, animated: true)
    }

    private func performDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let record = filteredRecords[indexPath.item]
        records.removeAll { $0.date == record.date }
        filteredRecords.remove(at: indexPath.item)

        try? Persistence.save(records)
        expandedIndexSet.removeAll()

        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        }, completion: { [weak self] _ in
            self?.setupAvailableYears()
            self?.filterRecords(for: self?.selectedYear)
            self?.updateEmptyState()
            self?.collectionView.reloadData()
            completion(true)
        })
    }
}
