//
//  MedicationViewController.swift
//  BreastCancerApp
//
//  Created by Shloka Shetty on 3/12/25.
//

import UIKit

class MedicationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var Cancel: UIBarButtonItem!
    @IBOutlet weak var AddButton: UIBarButtonItem!
    
    // MARK: - Data Source
    var allMedications: [Medication] = []
    var todaysMedications: [Medication] {
        let filtered = allMedications.filter { $0.isScheduledFor(date: Date()) }
        
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        loadMedications()
        setupNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setupNotificationObserver() {
        // Listen for medication updates from LogViewController
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(medicationDataDidChange),
            name: NSNotification.Name("MedicationDataUpdated"),
            object: nil
        )
    }
    
    @objc private func medicationDataDidChange() {
        // Reload medications from history
        loadMedications()
        collectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    func setupCollectionView() {
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - Cell Registration
    func registerCells() {
        // Register stats header cell
        collectionView.register(
            UINib(nibName: "MedicationStatsHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "stats_header"
        )
        
        // Register medication item cell
        collectionView.register(
            UINib(nibName: "MedicationItemCell", bundle: nil),
            forCellWithReuseIdentifier: "med_item"
        )

        // Register header view
        collectionView.register(
            UINib(nibName: "MedicationHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "med_header"
        )
        
        // Register cell for empty state
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "empty_state")
    }
    
    // MARK: - Load Medications
    func loadMedications() {
        if let history = MedicationHistory.shared.getHistory(for: Date()) {
            allMedications = history.medications
        } else {
            // If no history exists, initialize with dummy data
            loadDummyData()
        }
    }
    
    // MARK: - Load Dummy Data
    func loadDummyData() {
        allMedications = [
            Medication(name: "Aspirin", note: "Take with food", time: "8:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Vitamin D", note: "Morning supplement", time: "9:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Blood Pressure Med", note: "", time: "12:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Thyroid Medicine", note: "Take on empty stomach", time: "7:00 AM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true),
            Medication(name: "Omega-3", note: "", time: "6:00 PM", repeatOption: "Every Mon", isTaken: false, reminderEnabled: false),
            Medication(name: "Allergy Medicine", note: "Only if needed", time: "10:00 PM", repeatOption: "Every Day", isTaken: false, reminderEnabled: true)
        ]
        saveMedications()
    }
    
    // MARK: - Save Medications
    func saveMedications() {
        MedicationHistory.shared.saveMedications(allMedications, for: Date())
        
        // Post notification to update LogViewController
        NotificationCenter.default.post(
            name: NSNotification.Name("MedicationDataUpdated"),
            object: nil
        )
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Section 0: Stats, Section 1: Medications
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Stats header
        } else {
            return todaysMedications.isEmpty ? 1 : todaysMedications.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            // Stats header cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stats_header", for: indexPath) as? MedicationStatsHeaderCell else {
                return UICollectionViewCell()
            }
            
            let total = todaysMedications.count
            let taken = todaysMedications.filter { $0.isTaken }.count
            let missed = total - taken
            
            cell.configure(total: total, taken: taken, missed: missed)
            return cell
        }
        
        // Medication items
        if todaysMedications.isEmpty {
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
                label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20)
            ])
            
            cell.backgroundColor = .clear
            return cell
        }
            
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "med_item", for: indexPath) as? MedicationItemCell else {
            return UICollectionViewCell()
        }

        let med = todaysMedications[indexPath.row]
        cell.configureCell(with: med)

        cell.onCircleTapped = { [weak self, weak cell] in
            guard let self = self, let currentCell = cell else { return }
            
            guard let dynamicIndexPath = self.collectionView.indexPath(for: currentCell) else {
                return
            }
            
            let displayedMeds = self.todaysMedications
            if dynamicIndexPath.row >= displayedMeds.count {
                return
            }
            
            let medToToggle = displayedMeds[dynamicIndexPath.row]
            
            if let index = self.allMedications.firstIndex(where: {
                $0.name == medToToggle.name && $0.time == medToToggle.time && $0.repeatOption == medToToggle.repeatOption
            }) {
                self.allMedications[index].isTaken.toggle()
                
                // Reload both the item and the stats header
                self.collectionView.reloadItems(at: [dynamicIndexPath, IndexPath(item: 0, section: 0)])
                self.saveMedications()

                // Check if ALL today's medications are now taken → award coins (once per day)
                let allTaken = !self.todaysMedications.isEmpty &&
                               self.todaysMedications.allSatisfy({ $0.isTaken })
                CoinRewardService.shared.awardMedicationGoalIfEligible(
                    allTaken: allTaken,
                    on: self
                )
            }


        }

        return cell
    }
    
    // MARK: - Header Configuration
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "med_header",
                for: indexPath
            ) as! MedicationHeaderView
            
            if indexPath.section == 1 {
                header.configure(with: "Today")
            }
            
            return header
        }
        return UICollectionReusableView()
    }

    // MARK: - Layout Generation
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            if sectionIndex == 0 {
                // Stats header section
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
            } else {
                // Medication items section
                var config = UICollectionLayoutListConfiguration(appearance: .plain)
                config.backgroundColor = .clear
                config.showsSeparators = false
                config.headerMode = .supplementary
                
                config.itemSeparatorHandler = { indexPath, sectionSeparatorConfiguration in
                    var configuration = sectionSeparatorConfiguration
                    configuration.topSeparatorVisibility = .hidden
                    configuration.bottomSeparatorVisibility = .hidden
                    return configuration
                }
                
                config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                    guard let self = self else { return nil }
                    
                    if self.todaysMedications.isEmpty {
                        return nil
                    }
                    
                    let displayedMeds = self.todaysMedications
                    if indexPath.row >= displayedMeds.count {
                        return nil
                    }
                    
                    let medToEdit = displayedMeds[indexPath.row]
                    
                    guard let actualIndex = self.allMedications.firstIndex(where: {
                        $0.name == medToEdit.name && $0.time == medToEdit.time && $0.repeatOption == medToEdit.repeatOption
                    }) else {
                        return nil
                    }
                    
                    // DELETE ACTION
                    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                        self.confirmDelete(actualIndex: actualIndex, displayIndexPath: indexPath, completion: completion)
                    }
                    deleteAction.image = UIImage(systemName: "trash.fill")
                    deleteAction.backgroundColor = .systemRed
                    
                    // EDIT ACTION
                    let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, completion in
                        self.openEditMedication(actualIndex: actualIndex)
                        completion(true)
                    }
                    editAction.image = UIImage(systemName: "pencil")
                    editAction.backgroundColor = .systemBlue
                    
                    let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
                    swipeConfig.performsFirstActionWithFullSwipe = true
                    
                    return swipeConfig
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
        }
        
        return layout
    }
    
    // MARK: - Delete Confirmation
    func confirmDelete(actualIndex: Int, displayIndexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        
        let medName = allMedications[actualIndex].name
        
        let alert = UIAlertController(
            title: "Delete Medication?",
            message: "Are you sure you want to delete '\(medName)'?",
            preferredStyle: .alert
        )
        
        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.allMedications.remove(at: actualIndex)
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
    
    // MARK: - Edit Medication
    func openEditMedication(actualIndex: Int) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddMedicationViewController") as? AddMedicationViewController {
            let selectedMed = allMedications[actualIndex]
            addVC.medicationToEdit = selectedMed
            addVC.indexToEdit = actualIndex
            addVC.delegate = self
            
            // Present within the same navigation controller (no nested modal)
            navigationController?.pushViewController(addVC, animated: true)
        }
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddMedicationViewController") as? AddMedicationViewController {
            addVC.delegate = self
            
            // Present within the same navigation controller (no nested modal)
            navigationController?.pushViewController(addVC, animated: true)
        }
    }
}

// MARK: - AddMedicationDelegate
extension MedicationViewController: AddMedicationDelegate {
    
    func didAddMedication(name: String, time: String, repeatOption: String, note: String, reminderEnabled: Bool) {
        let newPill = Medication(name: name, note: note, time: time, repeatOption: repeatOption, isTaken: false, reminderEnabled: reminderEnabled)
        allMedications.append(newPill)
        collectionView.reloadData()
        saveMedications()
    }
    
    func didEditMedication(index: Int, name: String, time: String, repeatOption: String, note: String, reminderEnabled: Bool) {
        let updatedPill = Medication(name: name, note: note, time: time, repeatOption: repeatOption, isTaken: allMedications[index].isTaken, reminderEnabled: reminderEnabled)
        
        allMedications[index] = updatedPill
        collectionView.reloadData()
        saveMedications()
    }
}
