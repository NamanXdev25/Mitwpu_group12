//
//  MedicalLogViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import UIKit

class LogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataStore = LogsDataStore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        // Listen for Exercise updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(exerciseDataDidChange),
            name: ExerciseManager.exerciseDataDidChangeNotification,
            object: nil
        )
        
        // Listen for Hydration updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hydrationDataDidChange),
            name: NSNotification.Name("HydrationDataUpdated"),
            object: nil
        )
        
        // Listen for Appointment updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appointmentDataDidChange),
            name: NSNotification.Name("AppointmentDataUpdated"),
            object: nil
        )
        
        // Listen for Medication updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(medicationDataDidChange),
            name: NSNotification.Name("MedicationDataUpdated"),
            object: nil
        )
    }
    
    @objc private func exerciseDataDidChange() {
        // Reload only the stats section for better performance
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    @objc private func hydrationDataDidChange() {
        // Reload only the stats section for better performance
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    @objc private func appointmentDataDidChange() {
        // Reload appointment section
        collectionView.reloadSections(IndexSet(integer: 2))
    }
    
    @objc private func medicationDataDidChange() {
        // Reload medication section
        collectionView.reloadSections(IndexSet(integer: 3))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload sections to reflect updated data
        collectionView.reloadSections(IndexSet(integer: 1)) // Stats
        collectionView.reloadSections(IndexSet(integer: 2)) // Appointments
        collectionView.reloadSections(IndexSet(integer: 3)) // Medications
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        
        registerCells()
        
        let layout = generateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func registerCells() {
        // Register cells using XIB names directly
        collectionView.register(UINib(nibName: "LogsHeaderCell", bundle: nil), forCellWithReuseIdentifier: "LogsHeaderCell")
        collectionView.register(UINib(nibName: "LogsStatsRowCell", bundle: nil), forCellWithReuseIdentifier: "LogsStatsRowCell")
        collectionView.register(UINib(nibName: "LogsAppointmentCell", bundle: nil), forCellWithReuseIdentifier: "LogsAppointmentCell")
        collectionView.register(UINib(nibName: "CenteredMessageCell", bundle: nil), forCellWithReuseIdentifier: "CenteredMessageCell")
        collectionView.register(UINib(nibName: "LogsMedicationCell", bundle: nil), forCellWithReuseIdentifier: "LogsMedicationCell")
        collectionView.register(UINib(nibName: "LogsTrackingCell", bundle: nil), forCellWithReuseIdentifier: "LogsTrackingCell")
        
        // Register header
        collectionView.register(
            UINib(nibName: "LogsSectionHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "LogsSectionHeader"
        )
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Header
        case 1: return 1 // Stats Row
        case 2: return 1 // Appointment (always show, either appointment or empty message)
        case 3: return 1 // Medication (always show one - either next med or empty message)
        case 4: return dataStore.getHealthTracking().count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogsHeaderCell", for: indexPath) as! LogsHeaderCell
            let headerData = dataStore.getHeader()
            cell.configure(with: headerData)
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogsStatsRowCell", for: indexPath) as! LogsStatsRowCell
            let statsData = dataStore.getStats()
            cell.configure(with: statsData)
            cell.delegate = self
            return cell
            
        case 2:
            if let appointmentData = dataStore.getAppointment() {
                // Show appointment if available
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogsAppointmentCell", for: indexPath) as! LogsAppointmentCell
                cell.configure(with: appointmentData)
                return cell
            } else {
                // Show empty message if no appointments
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredMessageCell", for: indexPath) as! CenteredMessageCell
                cell.configure(message: "No appointments scheduled")
                return cell
            }
            
        case 3:
            // Check if all medications are taken
            if dataStore.areAllMedicationsTaken() {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredMessageCell", for: indexPath) as! CenteredMessageCell
                cell.configure(message: "All medications taken")
                return cell
            }
            // Check if there are no medications at all
            else if !dataStore.hasMedications() {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredMessageCell", for: indexPath) as! CenteredMessageCell
                cell.configure(message: "No medications added")
                return cell
            }
            // Show next medication
            else if let nextMed = dataStore.getNextMedication() {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogsMedicationCell", for: indexPath) as! LogsMedicationCell
                cell.configure(with: nextMed)
                
                // Handle tick button tap
                cell.onRadioButtonTapped = { [weak self] in
                    self?.dataStore.toggleMedicationStatus(pillName: nextMed.pillName, time: nextMed.time)
                    // Reload this section to show next medication
                    self?.collectionView.reloadSections(IndexSet(integer: 3))
                }
                
                return cell
            }
            // Fallback (should not reach here)
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredMessageCell", for: indexPath) as! CenteredMessageCell
                cell.configure(message: "No medications for today")
                return cell
            }
            
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogsTrackingCell", for: indexPath) as! LogsTrackingCell
            if let tracking = dataStore.getHealthTrackingItem(at: indexPath.row) {
                cell.configure(with: tracking)
                cell.delegate = self
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "LogsSectionHeader",
            for: indexPath
        ) as! LogsSectionHeader
        
        if let headerModel = dataStore.getSectionHeader(for: indexPath.section) {
            header.configure(with: headerModel, section: indexPath.section)
            header.delegate = self
        }
        
        return header
    }
    
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            
            // SECTION 0: Top Header
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                return section
            }
            
            // SECTION 1: Stats Row (moved up after header)
            else if sectionIndex == 1 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(165)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 10, trailing: 0)
                return section
            }
            
            // SECTION 2: Appointment Card (with section header)
            else if sectionIndex == 2 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(110)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(38))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                return section
            }
            
            // SECTION 3: Medication (Single cell for next medication)
            else if sectionIndex == 3 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                return section
            }
            
            // SECTION 4: Health Tracking (Last Section)
            else {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 120, trailing: 0)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(36))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                return section
            }
        }
    }
}

// MARK: - LogsStatsRowCell Delegate
extension LogViewController: LogsStatsRowCellDelegate {
    func didTapExercise() {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        if let exerciseVC = storyboard.instantiateViewController(withIdentifier: "ExerciseViewController") as? ExerciseViewController {
            navigationController?.pushViewController(exerciseVC, animated: true)
        }
    }
    
    func didTapHydration() {
        let storyboard = UIStoryboard(name: "hydration", bundle: nil)
        if let hydrationVC = storyboard.instantiateViewController(withIdentifier: "HydrationViewController") as? HydrationViewController {
            navigationController?.pushViewController(hydrationVC, animated: true)
        }
    }
}

//// MARK: - LogsTrackingCell Delegate
extension LogViewController: LogsTrackingCellDelegate {
    func didTapTrackingCell(with model: HealthTrackingModel) {
        if model.title == "Self-Exam Steps" {
            let storyboard = UIStoryboard(name: "selfexam", bundle: nil)
            guard let selfexamVC = storyboard.instantiateViewController(
                withIdentifier: "SelfExamineViewController"
            ) as? SelfExamineViewController else { return }
            
            navigationController?.pushViewController(selfexamVC, animated: true)
        } else if model.title == "Track Your Symptoms" {
            let storyboard = UIStoryboard(name: "symptomMain", bundle: nil)
            guard let symptomVC = storyboard.instantiateViewController(
               withIdentifier: "SymptomsViewController"
             ) as? SymptomsViewController else { return }
            navigationController?.pushViewController(symptomVC, animated: true)
        }
    }
}

// MARK: - LogsSectionHeader Delegate
extension LogViewController: LogsSectionHeaderDelegate {
    func didTapManageButton(for section: Int) {
        switch section {
        case 2: // Appointments
            let storyboard = UIStoryboard(name: "Appointments", bundle: nil)
            if let appointmentsVC = storyboard.instantiateViewController(
                withIdentifier: "CalendarViewController"
            ) as? AppointmentsViewController {
                navigationController?.pushViewController(appointmentsVC, animated: true)
            }
            
        case 3: // Medications
            let storyboard = UIStoryboard(name: "Medication", bundle: nil)
            if let medicationsVC = storyboard.instantiateViewController(
                withIdentifier: "MedicationViewController"
            ) as? MedicationViewController {
                // Wrap in navigation controller for modal presentation
                let navController = UINavigationController(rootViewController: medicationsVC)
                navController.modalPresentationStyle = .pageSheet
                
                if let sheet = navController.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
                
                present(navController, animated: true)
            }
            
        default:
            break
        }
    }
}
