import UIKit

final class TestHistoryViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate {
    @IBOutlet private var collectionView: UICollectionView!

    private var records: [TestRecord] = []
    private var filteredRecords: [TestRecord] = []
    private var expandedIndexSet = Set<Int>()

    private var selectedYear: Int?
    private var earliestLogYear: Int?

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

    // MARK: - Navigation Bar

    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Log History"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // remove nav bar hairline
        if let navBar = navigationController?.navigationBar {
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
            navBar.isTranslucent = true
            navBar.backgroundColor = .clear
        }
    }

    // MARK: - Collection View

    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear

        collectionView.register(
            UINib(nibName: "TestRecordCell", bundle: nil),
            forCellWithReuseIdentifier: "TestRecordCell"
        )
    }

    // MARK: - Data

    private func loadData() {
        records = Persistence.load()
        computeEarliestLogYear()
        filterRecords(for: selectedYear)
        collectionView.reloadData()
        updateEmptyState()
    }

    private func computeEarliestLogYear() {
        let calendar = Calendar.current

        guard !records.isEmpty else {
            let currentYear = calendar.component(.year, from: Date())
            earliestLogYear = currentYear
            selectedYear = currentYear
            return
        }

        let years = records.map { calendar.component(.year, from: $0.date) }
        earliestLogYear = years.min()
        selectedYear = selectedYear ?? years.max()
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
        if filteredRecords.isEmpty {
            let nib = UINib(nibName: "selfexamEmptyStateCell", bundle: nil)
            guard let view = nib.instantiate(withOwner: nil).first as? UIView else {
                collectionView.backgroundView = nil
                return
            }
            collectionView.backgroundView = view
        } else {
            collectionView.backgroundView = nil
        }
    }

    // MARK: - Notifications

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTestRecordAdded),
            name: .testRecordAdded,
            object: nil
        )
    }

    @objc private func handleTestRecordAdded(_: Notification) {
        loadData()
    }

    // MARK: - Filter Button

    @IBAction private func filterButtonTapped(_: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "selfexam", bundle: nil)

        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "YearFilterViewController"
        ) as? YearFilterViewController else { return }

        vc.earliestLogYear = earliestLogYear
        vc.selectedYear = selectedYear

        vc.onYearSelected = { [weak self] year in
            guard let self else { return }
            self.selectedYear = year
            self.filterRecords(for: year)
            self.expandedIndexSet.removeAll()
            self.collectionView.reloadData()
            self.updateEmptyState()
        }

        present(vc, animated: true)
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        filteredRecords.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TestRecordCell",
            for: indexPath
        ) as? TestRecordCell else {
            fatalError("Expected TestRecordCell for reuse identifier 'TestRecordCell' at \(indexPath)")
        }

        configureCell(cell, at: indexPath)
        return cell
    }

    private func configureCell(_ cell: TestRecordCell, at indexPath: IndexPath) {
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

    func collectionView(
        _: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        toggleExpansion(at: indexPath)
    }

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

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            self?.createSwipeActions(for: indexPath)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    // MARK: - Swipe Actions

    private func createSwipeActions(
        for indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
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

    private func confirmDelete(
        at indexPath: IndexPath,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(
            title: "Delete Record?",
            message: "Are you sure you want to delete this record?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            _ in completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] _ in
            self?.performDelete(at: indexPath, completion: completion)
        })

        present(alert, animated: true)
    }

    private func performDelete(
        at indexPath: IndexPath,
        completion: @escaping (Bool) -> Void
    ) {
        let record = filteredRecords[indexPath.item]
        records.removeAll { $0.date == record.date }
        filteredRecords.remove(at: indexPath.item)
        expandedIndexSet.removeAll()

        try? Persistence.save(records)

        loadData()
        completion(true)
    }
}
