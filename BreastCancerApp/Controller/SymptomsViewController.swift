import UIKit

class SymptomsViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var CloseButton: UIBarButtonItem!

    var displayDate: Date = .init()
    var onDismiss: (() -> Void)?

    private let dataSource = SymptomDataSource.shared
    private let calendar = Calendar.current
    private var userSymptoms: [Symptom] = []
    private var selectedSymptoms: [String: (severity: Int, note: String)] = [:]
    private var displayedLogs: [SymptomLog] = []
    private var lastLoadedDay = Calendar.current.startOfDay(for: Date())

    private enum Section: Int, CaseIterable {
        case log = 0
        case button = 1
        case today = 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadData()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCalendarDayChanged),
            name: Notification.Name.NSCalendarDayChanged,
            object: nil
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed || navigationController?.isBeingDismissed == true {
            onDismiss?()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NSCalendarDayChanged, object: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handleCalendarDayChanged() {
        guard isDisplayingToday else { return }
        displayDate = Date()
        loadData()
        NotificationCenter.default.post(name: NSNotification.Name("SymptomDataUpdated"), object: nil)
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()

        collectionView.register(UINib(nibName: "SymptomLogButtonCell", bundle: nil), forCellWithReuseIdentifier: "SymptomLogButtonCell")
        collectionView.register(UINib(nibName: "SymptomSelectionCell", bundle: nil), forCellWithReuseIdentifier: "SymptomSelectionCell")
        collectionView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellWithReuseIdentifier: "SymptomLogCell")

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")

        collectionView.register(
            UINib(nibName: "SymptomHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SymptomHeaderView.reuseIdentifier
        )
    }

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self,
                  let sectionType = Section(rawValue: sectionIndex)
            else {
                return nil
            }

            switch sectionType {
            case .log:
                return self.createLogSection()
            case .button:
                return self.createButtonSection()
            case .today:
                return self.createTodaySection(layoutEnvironment: layoutEnvironment)
            }
        }
    }

    private func createLogSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        section.interGroupSpacing = 8

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
        return section
    }

    private func createButtonSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(66)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(66)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

        return section
    }

    private func createTodaySection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = .clear
        config.headerMode = .supplementary
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard !self.displayedLogs.isEmpty else { return nil }

            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                self.confirmDelete(at: indexPath, completion: completion)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = .systemRed

            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
            swipeConfig.performsFirstActionWithFullSwipe = true

            return swipeConfig
        }

        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 8

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }

    private func loadData() {
        resetSelectionIfNeededForNewDay()
        userSymptoms = dataSource.getUserSymptoms()
        displayedLogs = dataSource.getSymptomLogs(on: normalizedDisplayDate)
        collectionView.reloadData()
    }

    private func resetSelectionIfNeededForNewDay() {
        guard normalizedDisplayDate != lastLoadedDay else { return }
        lastLoadedDay = normalizedDisplayDate
        selectedSymptoms.removeAll()
    }

    @objc private func logSymptomButtonTapped() {
        guard !selectedSymptoms.isEmpty else { return }

        for (symptomId, data) in selectedSymptoms {
            if let symptom = userSymptoms.first(where: { $0.id == symptomId }) {
                let noteToSave = data.note.trimmingCharacters(in: .whitespacesAndNewlines)
                dataSource.logSymptom(
                    symptomId: symptomId,
                    symptomName: symptom.name,
                    severity: data.severity,
                    note: noteToSave,
                    on: normalizedDisplayDate
                )
            }
        }

        selectedSymptoms.removeAll()
        displayedLogs = dataSource.getSymptomLogs(on: normalizedDisplayDate)
        collectionView.reloadSections(
            IndexSet([Section.log.rawValue,
                      Section.button.rawValue,
                      Section.today.rawValue])
        )

        NotificationCenter.default.post(name: NSNotification.Name("SymptomDataUpdated"), object: nil)
    }

    private func toggleSymptomSelection(symptomId: String) {
        guard let index = userSymptoms.firstIndex(where: { $0.id == symptomId }) else { return }

        if selectedSymptoms[symptomId] != nil {
            selectedSymptoms.removeValue(forKey: symptomId)
        } else {
            selectedSymptoms[symptomId] = (severity: 0, note: "")
        }
        let logIndexPath = IndexPath(item: index, section: Section.log.rawValue)
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [logIndexPath])
            collectionView.reloadSections(IndexSet([Section.button.rawValue]))
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let log = displayedLogs[indexPath.item]

        let alert = UIAlertController(
            title: "Delete Log?",
            message: "Are you sure you want to delete this \(log.symptomName) entry?",
            preferredStyle: .alert
        )

        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            self.dataSource.deleteLog(logId: log.id)
            self.displayedLogs = self.dataSource.getSymptomLogs(on: self.normalizedDisplayDate)
            if self.displayedLogs.isEmpty {
                self.collectionView.reloadSections(IndexSet([Section.today.rawValue]))
            } else {
                self.collectionView.deleteItems(at: [indexPath])
            }
            NotificationCenter.default.post(name: NSNotification.Name("SymptomDataUpdated"), object: nil)
            completion(true)
        }

        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }

        alert.addAction(deleteBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true)
    }

    private func showInfoAlert(for symptom: Symptom) {
        let message = dataSource.getDescription(for: symptom.name)
        let alert = UIAlertController(title: symptom.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func openEditList() {
        let storyboard = UIStoryboard(name: "symptomMain", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(
            withIdentifier: "EditSymptomListViewController"
        ) as? EditSymptomListViewController else {
            fatalError("Expected EditSymptomListViewController for storyboard identifier 'EditSymptomListViewController'")
        }

        editVC.onDismiss = { [weak self] in
            self?.loadData()
        }

        navigationController?.pushViewController(editVC, animated: true)
    }

    // MARK: - IBActions

    @IBAction func closeButtonTapped(_: UIBarButtonItem) {
        dismiss(animated: true)
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

extension SymptomsViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }

        switch sectionType {
        case .log:
            return userSymptoms.count
        case .button:
            return 1
        case .today:
            return displayedLogs.isEmpty ? 1 : displayedLogs.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        switch sectionType {
        case .log:
            return configureLogCell(collectionView: collectionView, indexPath: indexPath)
        case .button:
            return configureButtonCell(collectionView: collectionView, indexPath: indexPath)
        case .today:
            return configureTodayCell(collectionView: collectionView, indexPath: indexPath)
        }
    }

    private func configureLogCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomSelectionCell", for: indexPath) as? SymptomSelectionCell else {
            fatalError("Expected SymptomSelectionCell for reuse identifier 'SymptomSelectionCell' at \(indexPath)")
        }
        let symptom = userSymptoms[indexPath.item]
        let isSelected = selectedSymptoms[symptom.id] != nil
        let severity = selectedSymptoms[symptom.id]?.severity ?? 0
        let note = selectedSymptoms[symptom.id]?.note ?? ""

        cell.configure(with: symptom, isSelected: isSelected, severity: severity, note: note)

        cell.onCheckboxTapped = { [weak self] in
            self?.toggleSymptomSelection(symptomId: symptom.id)
        }

        cell.onSliderChanged = { [weak self] severity in
            guard let self = self else { return }
            if var current = self.selectedSymptoms[symptom.id] {
                current.severity = severity
                self.selectedSymptoms[symptom.id] = current
            }
        }

        cell.onNoteChanged = { [weak self] note in
            guard let self = self else { return }
            if var current = self.selectedSymptoms[symptom.id] {
                current.note = note
                self.selectedSymptoms[symptom.id] = current
            }
        }

        cell.onInfoTapped = { [weak self] in
            self?.showInfoAlert(for: symptom)
        }

        return cell
    }

    private func configureButtonCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomLogButtonCell", for: indexPath) as? SymptomLogButtonCell else {
            fatalError("Expected SymptomLogButtonCell for reuse identifier 'SymptomLogButtonCell' at \(indexPath)")
        }
        cell.configure(isEnabled: !selectedSymptoms.isEmpty)
        cell.onButtonTapped = { [weak self] in
            self?.logSymptomButtonTapped()
        }
        return cell
    }

    private func configureTodayCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        if displayedLogs.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)

            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            let label = UILabel()
            label.text = "No symptoms logged"
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
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomLogCell", for: indexPath) as? SymptomLogCell else {
                fatalError("Expected SymptomLogCell for reuse identifier 'SymptomLogCell' at \(indexPath)")
            }
            let log = displayedLogs[indexPath.item]
            cell.configure(with: log)
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = Section(rawValue: indexPath.section)
        else {
            return UICollectionReusableView()
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SymptomHeaderView.reuseIdentifier,
            for: indexPath
        ) as? SymptomHeaderView else {
            fatalError("Expected SymptomHeaderView for reuse identifier '\(SymptomHeaderView.reuseIdentifier)' at \(indexPath)")
        }

        switch sectionType {
        case .log:
            header.configure(title: "Log", showButton: true)
            header.editTapped = { [weak self] in
                self?.openEditList()
            }
        case .today:
            header.configure(title: displayedDateSectionTitle, showButton: false)
            header.editTapped = nil
        case .button:
            return UICollectionReusableView()
        }

        return header
    }
}

extension SymptomsViewController: UICollectionViewDelegate {}
