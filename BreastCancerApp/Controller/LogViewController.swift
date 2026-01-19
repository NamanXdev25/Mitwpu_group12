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
        case 2: return 1 // Appointment
        case 3: return dataStore.getMedications().count
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogsAppointmentCell", for: indexPath) as! LogsAppointmentCell
            let appointmentData = dataStore.getAppointment()
            cell.configure(with: appointmentData)
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogsMedicationCell", for: indexPath) as! LogsMedicationCell
            if let medication = dataStore.getMedication(at: indexPath.row) {
                cell.configure(with: medication)
            }
            return cell
            
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
            
            // SECTION 3: Medications
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
        // Handle hydration tap if needed
    }
}
// MARK: - LogsTrackingCell Delegate
extension LogViewController: LogsTrackingCellDelegate {
    func didTapTrackingCell(with model: HealthTrackingModel) {
        // Check which cell was tapped based on the title or add an identifier to HealthTrackingModel
        if model.title == "Self-Exam Steps" {
            let storyboard = UIStoryboard(name: "selfexam", bundle: nil)
            guard let selfexamVC = storyboard.instantiateViewController(
                withIdentifier: "SelfExamineViewController"
            ) as? SelfExamineViewController else { return }
            
            navigationController?.pushViewController(selfexamVC, animated: true)
        } else if model.title == "Track Your Symptoms" {
            // Navigate to symptom tracking screen
             let storyboard = UIStoryboard(name: "symptomMain", bundle: nil)
            guard let symptomVC = storyboard.instantiateViewController(
               withIdentifier: "SymptomsViewController"
             ) as? SymptomsViewController else { return }
                navigationController?.pushViewController(symptomVC, animated: true)
            print("Navigate to Symptom Tracking")
        }
    }
}
// MARK: - LogsSectionHeader Delegate
extension LogViewController: LogsSectionHeaderDelegate {
    func didTapManageButton(for section: Int) {
        switch section {
        case 2: // Appointments
            // Navigate to manage appointments screen
            let storyboard = UIStoryboard(name: "Appointments", bundle: nil)
            if let appointmentsVC = storyboard.instantiateViewController(
                withIdentifier: "CalendarViewController"
            ) as? AppointmentsViewController {
                navigationController?.pushViewController(appointmentsVC, animated: true)
            }
            print("Navigate to Manage Appointments")
            
        case 3: // Medications
            // Navigate to manage medications screen
            let storyboard = UIStoryboard(name: "Medication", bundle: nil)
            if let medicationsVC = storyboard.instantiateViewController(
                withIdentifier: "MedicationViewController"
            ) as? MedicationViewController {
                navigationController?.pushViewController(medicationsVC, animated: true)
            }
            print("Navigate to Manage Medications")
            
        default:
            break
        }
    }
}
