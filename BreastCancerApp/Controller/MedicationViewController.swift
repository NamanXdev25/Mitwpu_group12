//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Shloka Shetty on 3/12/25.
//
import UIKit

class MedicationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var calendarBarButton: UIBarButtonItem!

    // MARK: - Data Source
    var allMedications: [Medication] = []  // Store ALL medications
    var todaysMedications: [Medication] {
        let filtered = allMedications.filter { $0.isScheduledFor(date: Date()) }
        
        // Sort by time in ascending order (AM to PM)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    // MARK: - Setup
    func setupCollectionView() {
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - Cell Registration
    func registerCells() {
        collectionView.register(
            UINib(nibName: "MedicationItemCell", bundle: nil),
            forCellWithReuseIdentifier: "med_item"
        )

        collectionView.register(
            UINib(nibName: "MedicationHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "med_header"
        )
        
        // Register a basic cell for empty state
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "empty_state")
    }
    
    // MARK: - Load Medications
    func loadMedications() {
        // Load all medications from history for today
        if let history = MedicationHistory.shared.getHistory(for: Date()) {
            allMedications = history.medications
        } else {
            // If no medications exist for today, load dummy data
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
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return 1 if empty to show the empty state cell
        return todaysMedications.isEmpty ? 1 : todaysMedications.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Show empty state if no medications
        if todaysMedications.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "empty_state", for: indexPath)
            
            // Configure empty state cell
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
            
            // Find this medication in allMedications and toggle it
            if let index = self.allMedications.firstIndex(where: {
                $0.name == medToToggle.name && $0.time == medToToggle.time && $0.repeatOption == medToToggle.repeatOption
            }) {
                self.allMedications[index].isTaken.toggle()
                self.collectionView.reloadItems(at: [dynamicIndexPath])
                self.saveMedications()
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
            
            header.configure(with: "Today's Medications")
            return header
        }
        return UICollectionReusableView()
    }

    // MARK: - Layout Generation (With Edit & Delete)
    func generateLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.showsSeparators = false
        config.headerMode = .supplementary
        config.showsSeparators = true
        
        var bgConfig = UIBackgroundConfiguration.clear()
        bgConfig.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.96, alpha: 1.0)
        config.backgroundColor = bgConfig.backgroundColor

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            // Don't show swipe actions for empty state
            if self.todaysMedications.isEmpty {
                return nil
            }
            
            let displayedMeds = self.todaysMedications
            if indexPath.row >= displayedMeds.count {
                return nil
            }
            
            let medToEdit = displayedMeds[indexPath.row]
            
            // Find the actual index in allMedications
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
        
        return UICollectionViewCompositionalLayout.list(using: config)
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
            
            // Remove from allMedications
            self.allMedications.remove(at: actualIndex)
            self.saveMedications()
            
            // Reload entire collection view instead of trying to delete specific item
            // This avoids the invalid update error since todaysMedications is computed
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
        
        if let navController = storyboard.instantiateViewController(withIdentifier: "AddMedicationNavController") as? UINavigationController {
            if let addVC = navController.topViewController as? AddMedicationViewController {
                let selectedMed = allMedications[actualIndex]
                addVC.medicationToEdit = selectedMed
                addVC.indexToEdit = actualIndex
                addVC.delegate = self
            }
            
            navController.modalPresentationStyle = .pageSheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(navController, animated: true)
        }
    }
    
    // MARK: - IBActions
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        
        if let navController = storyboard.instantiateViewController(withIdentifier: "AddMedicationNavController") as? UINavigationController {
            if let addVC = navController.topViewController as? AddMedicationViewController {
                addVC.delegate = self
            }
            
            navController.modalPresentationStyle = .pageSheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(navController, animated: true)
        }
    }
    
    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        if let calendarNavController = storyboard.instantiateViewController(withIdentifier: "MedicationCalendarViewController") as? UINavigationController {
            calendarNavController.modalPresentationStyle = .pageSheet
            if let sheet = calendarNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            self.present(calendarNavController, animated: true, completion: nil)
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
