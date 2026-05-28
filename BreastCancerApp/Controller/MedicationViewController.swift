import UIKit

class MedicationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var Cancel: UIBarButtonItem!
    @IBOutlet var AddButton: UIBarButtonItem!

    var displayDate: Date = .init()
    var onDismiss: (() -> Void)?

    private let calendar = Calendar.current
    var allMedications: [Medication] = []
    var displayedDateMedications: [Medication] {
        let filtered = allMedications.filter { $0.isScheduledFor(date: normalizedDisplayDate) }
        return filtered.sorted { med1, med2 in
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date1 = timeFormatter.date(from: med1.time),
               let date2 = timeFormatter.date(from: med2.time) {
                return date1 < date2
            }
            return med1.time < med2.time
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        loadMedications()
        setupNotificationObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedications()
        collectionView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || navigationController?.isBeingDismissed == true {
            onDismiss?()
        }
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(medicationDataDidChange),
            name: NSNotification.Name("MedicationDataUpdated"),
            object: nil
        )
    }

    @objc private func medicationDataDidChange() {
        loadMedications()
        collectionView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupCollectionView() {
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func registerCells() {
        collectionView.register(
            UINib(nibName: "MedicationStatsHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "stats_header"
        )
        collectionView.register(
            UINib(nibName: "MedicationItemCell", bundle: nil),
            forCellWithReuseIdentifier: "med_item"
        )
        collectionView.register(
            UINib(nibName: "MedicationHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "med_header"
        )
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "empty_state")
    }

    func loadMedications() {
        if let history = MedicationHistory.shared.getHistory(for: normalizedDisplayDate) {
            allMedications = history.medications
        }
    }

    func loadDummyData() {
        allMedications = [
            Medication(name: "Aspirin", note: "Take with food", time: "8:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Vitamin D", note: "Morning supplement", time: "9:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Blood Pressure Med", note: "", time: "12:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(
                name: "Thyroid Medicine",
                note: "Take on empty stomach",
                time: "7:00 AM",
                repeatOption: "Every Day",
                isTaken: false,
                reminderEnabled: true
            ),
            Medication(name: "Omega-3", note: "", time: "6:00 PM", repeatOption: "Every Mon", isTaken: false, reminderEnabled: false),
            Medication(name: "Allergy Medicine", note: "Only if needed", time: "10:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
        ]
        saveMedications()
    }

    func saveMedications() {
        MedicationHistory.shared.saveMedications(allMedications, for: normalizedDisplayDate)
        NotificationCenter.default.post(
            name: NSNotification.Name("MedicationDataUpdated"),
            object: nil
        )
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return displayedDateMedications.isEmpty ? 1 : displayedDateMedications.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return configureHeaderCell(collectionView: collectionView, indexPath: indexPath)
        }

        if displayedDateMedications.isEmpty {
            return configureEmptyStateCell(collectionView: collectionView, indexPath: indexPath)
        }

        return configureMedicationCell(collectionView: collectionView, indexPath: indexPath)
    }

    private func configureHeaderCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stats_header", for: indexPath) as? MedicationStatsHeaderCell else {
            return UICollectionViewCell()
        }

        let meds = displayedDateMedications
        if meds.isEmpty {
            cell.configureEmpty()
        } else {
            let total = meds.count
            let taken = meds.filter { $0.isTaken }.count
            let missed = meds.filter { med in
                guard !med.isTaken else { return false }
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                guard let scheduledTime = formatter.date(from: med.time) else { return false }
                let cal = Calendar.current
                let components = cal.dateComponents([.hour, .minute], from: scheduledTime)
                guard let scheduledToday = cal.date(
                    bySettingHour: components.hour ?? 0,
                    minute: components.minute ?? 0,
                    second: 0,
                    of: normalizedDisplayDate
                ) else { return false }
                return Date() > scheduledToday.addingTimeInterval(5 * 60)
            }.count
            cell.configure(total: total, taken: taken, missed: missed)
        }
        return cell
    }

    private func configureEmptyStateCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "empty_state", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.text = "No medications added"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
        ])

        cell.backgroundColor = .clear
        return cell
    }

    private func configureMedicationCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "med_item", for: indexPath) as? MedicationItemCell else {
            return UICollectionViewCell()
        }

        let med = displayedDateMedications[indexPath.row]
        cell.configureCell(with: med)

        cell.onCircleTapped = { [weak self, weak cell] in
            guard let self = self, let currentCell = cell else { return }
            guard let dynamicIndexPath = self.collectionView.indexPath(for: currentCell) else { return }

            let displayedMeds = self.displayedDateMedications
            if dynamicIndexPath.row >= displayedMeds.count { return }

            let medToToggle = displayedMeds[dynamicIndexPath.row]

            if let index = self.allMedications.firstIndex(where: {
                $0.name == medToToggle.name && $0.time == medToToggle.time && $0.repeatOption == medToToggle.repeatOption
            }) {
                self.allMedications[index].isTaken.toggle()
                self.collectionView.reloadItems(at: [dynamicIndexPath, IndexPath(item: 0, section: 0)])
                self.saveMedications()

                if self.isDisplayingToday {
                    let allTaken = !self.displayedDateMedications.isEmpty &&
                        self.displayedDateMedications.allSatisfy { $0.isTaken }
                    CoinRewardService.shared.awardMedicationGoalIfEligible(
                        allTaken: allTaken,
                        on: self
                    )
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "med_header",
                for: indexPath
            ) as? MedicationHeaderView else {
                fatalError("Expected MedicationHeaderView for reuse identifier 'med_header' at \(indexPath)")
            }

            if indexPath.section == 1 {
                header.configure(with: displayedDateSectionTitle)
            }

            return header
        }
        return UICollectionReusableView()
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                return self?.createStatsSection()
            } else {
                return self?.createListSection(environment: environment)
            }
        }
    }

    private func createStatsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(90)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        return section
    }

    private func createListSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .clear
        config.showsSeparators = false
        config.headerMode = .supplementary

        config.itemSeparatorHandler = { _, sectionSeparatorConfiguration in
            var configuration = sectionSeparatorConfiguration
            configuration.topSeparatorVisibility = .hidden
            configuration.bottomSeparatorVisibility = .hidden
            return configuration
        }

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            return self?.createSwipeActions(for: indexPath)
        }

        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }

    private func createSwipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if displayedDateMedications.isEmpty { return nil }
        let displayedMeds = displayedDateMedications
        if indexPath.row >= displayedMeds.count { return nil }
        let medToEdit = displayedMeds[indexPath.row]

        guard let actualIndex = allMedications.firstIndex(where: {
            $0.name == medToEdit.name && $0.time == medToEdit.time && $0.repeatOption == medToEdit.repeatOption
        }) else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.confirmDelete(actualIndex: actualIndex, displayIndexPath: indexPath, completion: completion)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            self?.openEditMedication(actualIndex: actualIndex)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue

        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        swipeConfig.performsFirstActionWithFullSwipe = true
        return swipeConfig
    }

    func confirmDelete(actualIndex: Int, displayIndexPath _: IndexPath, completion: @escaping (Bool) -> Void) {
        let medName = allMedications[actualIndex].name
        let alert = UIAlertController(
            title: "Delete Medication?",
            message: "Are you sure you want to delete '\(medName)'?",
            preferredStyle: .alert
        )
        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.allMedications.remove(at: actualIndex)
            MedicationReminderScheduler.shared.syncReminders(for: self.allMedications, showPermissionAlert: false)
            self.saveMedications()
            self.collectionView.reloadData()
            completion(true)
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        alert.addAction(deleteBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true)
    }

    func openEditMedication(actualIndex: Int) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(withIdentifier: "NewAddMedicationViewController") as? NewAddMedicationViewController
        else { return }
        addVC.medicationToEdit = allMedications[actualIndex]
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }

    @IBAction func cancelButtonTapped(_: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func addButtonTapped(_: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(withIdentifier: "NewAddMedicationViewController") as? NewAddMedicationViewController
        else { return }
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }

    private var normalizedDisplayDate: Date {
        calendar.startOfDay(for: displayDate)
    }

    private var isDisplayingToday: Bool {
        calendar.isDateInToday(normalizedDisplayDate)
    }

    private var displayedDateSectionTitle: String {
        if isDisplayingToday {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: normalizedDisplayDate)
    }
}

extension MedicationViewController: NewAddMedicationDelegate {
    func didSaveMedications(_ medications: [Medication], editedId: String?) {
        let idToRemove = editedId ?? medications.first?.id
        if let targetId = idToRemove,
           let existingIndex = allMedications.firstIndex(where: { $0.id == targetId }) {
            allMedications.remove(at: existingIndex)
        }
        allMedications.append(contentsOf: medications)
        MedicationReminderScheduler.shared.syncReminders(for: allMedications)
        saveMedications()
        collectionView.reloadData()
    }
}
