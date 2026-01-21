import UIKit

final class TestHistoryViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate {

    @IBOutlet private weak var collectionView: UICollectionView!

    private var records: [TestRecord] = []
    private var filteredRecords: [TestRecord] = []
    private var expandedIndexSet = Set<Int>()

    private var availableYears: [Int] = []
    private var selectedYear: Int?

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

        collectionView.register(
            UINib(nibName: "EmptyStateCell", bundle: nil),
            forCellWithReuseIdentifier: selfexamEmptyStateCell.reuseIdentifier
        )
    }

    private func loadData() {
        records = Persistence.load()
        setupAvailableYears()
        filterRecords(for: selectedYear)
        collectionView.reloadData()
    }

    private func setupAvailableYears() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let minimumFutureYear = currentYear + 5

        guard !records.isEmpty else {
            availableYears = Array(currentYear...minimumFutureYear)
            selectedYear = selectedYear ?? currentYear
            return
        }

        let recordYears = records.map {
            calendar.component(.year, from: $0.date)
        }

        guard
            let earliestYear = recordYears.min(),
            let latestRecordYear = recordYears.max()
        else {
            availableYears = Array(currentYear...minimumFutureYear)
            selectedYear = selectedYear ?? currentYear
            return
        }

        let endYear = max(minimumFutureYear, latestRecordYear)
        availableYears = Array(earliestYear...endYear)

        if let selectedYear, availableYears.contains(selectedYear) {
            self.selectedYear = selectedYear
        } else {
            self.selectedYear = currentYear
        }
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
        collectionView.reloadData()
    }

    @IBAction private func filterButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "selfexam", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "YearFilterViewController"
        ) as? YearFilterViewController else { return }

        vc.years = availableYears
        vc.selectedYear = selectedYear

        vc.onYearSelected = { [weak self] year in
            guard let self else { return }
            self.selectedYear = year
            self.filterRecords(for: year)
            self.expandedIndexSet.removeAll()
            self.collectionView.reloadData()
        }

        present(vc, animated: true)
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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        filteredRecords.isEmpty ? 1 : filteredRecords.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if filteredRecords.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: selfexamEmptyStateCell.reuseIdentifier,
                for: indexPath
            ) as! selfexamEmptyStateCell
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TestRecordCell",
            for: indexPath
        ) as! TestRecordCell

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
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        !filteredRecords.isEmpty
    }

    func collectionView(
        _ collectionView: UICollectionView,
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

    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = true
        config.backgroundColor = .clear

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            self?.createSwipeActions(for: indexPath)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

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

    func confirmDelete(
        at indexPath: IndexPath,
        completion: @escaping (Bool) -> Void
    ) {
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

    private func performDelete(
        at indexPath: IndexPath,
        completion: @escaping (Bool) -> Void
    ) {
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
            self?.collectionView.reloadData()
            completion(true)
        })
    }
}
