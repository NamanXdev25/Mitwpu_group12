//
//  SymptomsViewController.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class SymptomsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var CloseButton: UIBarButtonItem!
    
    private let dataSource = SymptomDataSource.shared
    private var userSymptoms: [Symptom] = []
    private var selectedSymptoms: [String: (severity: Int, note: String)] = [:]
    private var todayLogs: [SymptomLog] = []
    private var lastLoadedDay = Calendar.current.startOfDay(for: Date())
    
    private enum Section: Int, CaseIterable {
        case log = 0
        case button = 1
        case today = 2
    }
    
    // override funcs
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
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NSCalendarDayChanged, object: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handleCalendarDayChanged() {
        loadData()
        NotificationCenter.default.post(name: NSNotification.Name("SymptomDataUpdated"), object: nil)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        
        // Register cells
        collectionView.register(UINib(nibName: "SymptomLogButtonCell", bundle: nil), forCellWithReuseIdentifier: "SymptomLogButtonCell")
        collectionView.register(UINib(nibName: "SymptomSelectionCell", bundle: nil), forCellWithReuseIdentifier: "SymptomSelectionCell")
        collectionView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellWithReuseIdentifier: "SymptomLogCell")
        
        // Register plain cell for empty state
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
        
        collectionView.register(
            UINib(nibName: "SymptomHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SymptomHeaderView.reuseIdentifier
        )
    }
    
    // collection view layout
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self,
                  let sectionType = Section(rawValue: sectionIndex) else {
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
        
        return layout
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
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(66)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(66)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
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
            guard !self.todayLogs.isEmpty else { return nil }
            
            // delete functionality
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
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
        
        // header
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
        todayLogs = dataSource.getTodayLogs()
        collectionView.reloadData()
    }

    private func resetSelectionIfNeededForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        guard today != lastLoadedDay else { return }
        lastLoadedDay = today
        selectedSymptoms.removeAll()
    }
    
    @objc private func logSymptomButtonTapped() {
        guard !selectedSymptoms.isEmpty else { return }

        for (symptomId, data) in selectedSymptoms {
            if let symptom = userSymptoms.first(where: { $0.id == symptomId }) {
                // Only save note if it's not empty
                let noteToSave = data.note.trimmingCharacters(in: .whitespacesAndNewlines)
                dataSource.logSymptom(
                    symptomId: symptomId,
                    symptomName: symptom.name,
                    severity: data.severity,
                    note: noteToSave
                )
            }
        }

        selectedSymptoms.removeAll()
        todayLogs = dataSource.getTodayLogs()
        collectionView.reloadSections(
            IndexSet([Section.log.rawValue,
                      Section.button.rawValue,
                      Section.today.rawValue])
        )

        // Notify CareScreen to refresh its symptoms chip immediately
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
    
    // delete confirmation
    private func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let log = todayLogs[indexPath.item]
        
        let alert = UIAlertController(
            title: "Delete Log?",
            message: "Are you sure you want to delete this \(log.symptomName) entry?",
            preferredStyle: .alert
        )
        
        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.dataSource.deleteLog(logId: log.id)
            self.todayLogs = self.dataSource.getTodayLogs()
            if self.todayLogs.isEmpty {
                self.collectionView.reloadSections(IndexSet([Section.today.rawValue]))
            } else {
                self.collectionView.deleteItems(at: [indexPath])
            }
            // Notify CareScreen to refresh its symptoms chip immediately
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
        let editVC = storyboard.instantiateViewController(
            withIdentifier: "EditSymptomListViewController"
        ) as! EditSymptomListViewController

        editVC.onDismiss = { [weak self] in
            self?.loadData()
        }

        // Push within the same navigation controller (no nested modal)
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// UICollectionViewDataSource
extension SymptomsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .log:
            return userSymptoms.count
        case .button:
            return 1
        case .today:
            return todayLogs.isEmpty ? 1 : todayLogs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType {
        case .log:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomSelectionCell", for: indexPath) as! SymptomSelectionCell
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
            
        case .button:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomLogButtonCell", for: indexPath) as! SymptomLogButtonCell
            cell.configure(isEnabled: !selectedSymptoms.isEmpty)
            cell.onButtonTapped = { [weak self] in
                self?.logSymptomButtonTapped()
            }
            return cell
            
        case .today:
            if todayLogs.isEmpty {
                // Use a plain UICollectionViewCell as fallback for empty state
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
                
                // Remove any existing subviews
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                
                // Create and configure label
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
                    label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20)
                ])
                
                cell.backgroundColor = .clear
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomLogCell", for: indexPath) as! SymptomLogCell
                let log = todayLogs[indexPath.item]
                cell.configure(with: log)
                return cell
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = Section(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SymptomHeaderView.reuseIdentifier,
            for: indexPath
        ) as! SymptomHeaderView

        switch sectionType {
        case .log:
            header.configure(title: "Log", showButton: true)
            header.editTapped = { [weak self] in
                self?.openEditList()
            }
        case .today:
            header.configure(title: "Today", showButton: false)
            header.editTapped = nil
        case .button:
            return UICollectionReusableView()
        }
        
        return header
    }
}

// UICollectionViewDelegate
extension SymptomsViewController: UICollectionViewDelegate {
    
}
