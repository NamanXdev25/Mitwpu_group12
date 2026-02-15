//
//  CareScreenViewController.swift
//  BreastCancerApp
//
//  Rewritten using DiffableDataSource pattern
//

import UIKit

class CareScreenViewController: UIViewController {

    @IBOutlet weak var CareCollectionView: UICollectionView!
    
    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<CareSectionType, CareItem>!
    
    // Expansion state
    private var isHydrationExpanded = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setupCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    // MARK: - Register Cells
    private func registerCells() {
        let cellIdentifiers = [
            "CareHeaderCell",
            "CareHydrationCell",
            "CareMedicationCell",
            "CareDailyExerciseCell",
            "CareSymptomsCell",
            "CareAppointmentsCell",
            "CareViewInsightsCell"
        ]
        
        for identifier in cellIdentifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            CareCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        CareCollectionView.collectionViewLayout = createCompositionalLayout()
        CareCollectionView.delegate = self
        CareCollectionView.backgroundColor = UIColor(named: "logsbgcolor") ?? .systemBackground
        CareCollectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    // MARK: - Create Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let sectionType = CareSectionType(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .todayHeader:      return self.createHeaderSection()
            case .hydration:        return self.createHydrationSection()
            case .medication:       return self.createMedicationSection()
            case .exercise:         return self.createExerciseSection()
            case .symptoms:         return self.createSymptomsSection()
            case .appointmentHeader: return self.createHeaderSection()
            case .appointments:     return self.createAppointmentsSection()
            case .healthInsights:   return self.createHealthInsightsSection()
            }
        }
    }
    
    // MARK: - Section Layouts
    
    // Header Section (for "Today" and "Appointments" headers)
    private func createHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(55)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(55)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        return section
    }
    
    // Hydration Section
    private func createHydrationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(209)  // Larger for expandable content
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(209)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    // Medication Section
    private func createMedicationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
        
        return section
    }
    
    // Exercise Section
    private func createExerciseSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
        
        return section
    }
    
    // Symptoms Section
    private func createSymptomsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        return section
    }
    
    // Appointments Section
    private func createAppointmentsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(109)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(109)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 22, trailing: 16)
        section.interGroupSpacing = 12  // Space between multiple appointments
        
        return section
    }
    
    // Health Insights Section
    private func createHealthInsightsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(56)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(56)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16)
        
        return section
    }
    
    // MARK: - Configure Data Source
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<CareSectionType, CareItem>(
            collectionView: CareCollectionView
        ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let self = self else { return nil }
            
            switch item.type {
            case .header(let title, let showManage):
                return self.configureHeaderCell(collectionView, indexPath: indexPath, title: title, showManage: showManage)
                
            case .hydration:
                return self.configureHydrationCell(collectionView, indexPath: indexPath)
                
            case .medication(let title, let status, let imageName):
                return self.configureMedicationCell(collectionView, indexPath: indexPath, title: title, status: status, imageName: imageName)
                
            case .exercise(let title, let duration, let imageName):
                return self.configureExerciseCell(collectionView, indexPath: indexPath, title: title, duration: duration, imageName: imageName)
                
            case .symptoms(let title, let loggedSymptoms):
                return self.configureSymptomsCell(collectionView, indexPath: indexPath, title: title, symptoms: loggedSymptoms)
                
            case .appointment(let month, let day, let title, let doctor, let time):
                return self.configureAppointmentCell(collectionView, indexPath: indexPath, month: month, day: day, title: title, doctor: doctor, time: time)
                
            case .healthInsights:
                return self.configureHealthInsightsCell(collectionView, indexPath: indexPath)
            }
        }
    }
    
    // MARK: - Cell Configuration Methods
    
    private func configureHeaderCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, showManage: Bool) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareHeaderCell",
            for: indexPath
        ) as! CareHeaderCell
        cell.configure(title: title, showManage: showManage)
        return cell
    }
    
    private func configureHydrationCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareHydrationCell",
            for: indexPath
        ) as! CareHydrationCell
        cell.configure(
            isExpanded: isHydrationExpanded,
            progress: 0.66,
            currentAmount: "2/3 Ltr",
            goal: "3.0 L",
            cupSize: "200 mL"
        )
        return cell
    }
    
    private func configureMedicationCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, status: String, imageName: String?) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareMedicationCell",
            for: indexPath
        ) as! CareMedicationCell
        let image = imageName != nil ? UIImage(named: imageName!) : UIImage(systemName: "pills.fill")
        cell.configure(title: title, status: status, image: image)
        cell.delegate = self
        return cell
    }
    
    private func configureExerciseCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, duration: String, imageName: String?) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareDailyExerciseCell",
            for: indexPath
        ) as! CareDailyExerciseCell
        let image = imageName != nil ? UIImage(named: imageName!) : UIImage(systemName: "figure.mixed.cardio")
        cell.configure(title: title, duration: duration, image: image)
        return cell
    }
    
    private func configureSymptomsCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, symptoms: [String]) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareSymptomsCell",
            for: indexPath
        ) as! CareSymptomsCell
        cell.configure(title: title, loggedSymptoms: symptoms)
        cell.delegate = self
        return cell
    }
    
    private func configureAppointmentCell(_ collectionView: UICollectionView, indexPath: IndexPath, month: String, day: String, title: String, doctor: String, time: String) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareAppointmentsCell",
            for: indexPath
        ) as! CareAppointmentsCell
        cell.configure(month: month, day: day, title: title, doctor: doctor, time: time)
        return cell
    }
    
    private func configureHealthInsightsCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareViewInsightsCell",
            for: indexPath
        ) as! CareViewInsightsCell
        // Configure with any data needed
        return cell
    }
    
    // MARK: - Apply Snapshot
    private func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<CareSectionType, CareItem>()
        
        // Add all sections
        snapshot.appendSections(CareSectionType.allCases)
        
        // Today Header
        snapshot.appendItems([
            CareItem(id: UUID(), type: .header(title: "Today", showManage: false))
        ], toSection: .todayHeader)
        
        // Hydration
        snapshot.appendItems([
            CareItem(id: UUID(), type: .hydration)
        ], toSection: .hydration)
        
        // Medication
        snapshot.appendItems([
            CareItem(id: UUID(), type: .medication(
                title: "Medication",
                status: "2/3 Taken",
                imageName: nil
            ))
        ], toSection: .medication)
        
        // Exercise
        snapshot.appendItems([
            CareItem(id: UUID(), type: .exercise(
                title: "Daily Exercises",
                duration: "15 min",
                imageName: nil
            ))
        ], toSection: .exercise)
        
        // Symptoms
        snapshot.appendItems([
            CareItem(id: UUID(), type: .symptoms(
                title: "Symptoms logged",
                loggedSymptoms: ["Fatigue", "Nausea", "Pain", "+2"]
            ))
        ], toSection: .symptoms)
        
        // Appointments Header
        snapshot.appendItems([
            CareItem(id: UUID(), type: .header(title: "Appointments", showManage: true))
        ], toSection: .appointmentHeader)
        
        // Appointments
        snapshot.appendItems([
            CareItem(id: UUID(), type: .appointment(
                month: "JAN",
                day: "28",
                title: "Oncology Check-Up",
                doctor: "Dr. Sarah Johnson",
                time: "10:30 AM"
            ))
        ], toSection: .appointments)
        
        // Health Insights
        snapshot.appendItems([
            CareItem(id: UUID(), type: .healthInsights)
        ], toSection: .healthInsights)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate
extension CareScreenViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item.type {
        case .hydration:
            // Toggle hydration expansion
            isHydrationExpanded.toggle()
            applySnapshot(animatingDifferences: true)
            
        case .medication(let title, _, _):
            print("👆 Selected medication: \(title)")
            
        case .exercise(let title, _, _):
            print("👆 Selected exercise: \(title)")
            
        case .symptoms:
            print("👆 View all symptoms tapped")
            
        case .appointment(_, _, let title, _, _):
            print("👆 Selected appointment: \(title)")
            
        case .healthInsights:
            print("👆 View health insights tapped")
            
        default:
            break
        }
    }
}

extension CareScreenViewController: CareMedicationCellDelegate {
    func careMedicationCellDidTap(_ cell: CareMedicationCell) {
        // Navigate to MedicationViewController modally
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        if let medicationVC = storyboard.instantiateViewController(withIdentifier: "MedicationViewController") as? MedicationViewController {
            
            let navController = UINavigationController(rootViewController: medicationVC)
            
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            
            present(navController, animated: true)
        }
    }
}

// MARK: - CareSymptomsCellDelegate
extension CareScreenViewController: CareSymptomsCellDelegate {
    func careSymptomsCellDidTapViewInsights(_ cell: CareSymptomsCell) {
        // Navigate to SymptomsViewController modally
        let storyboard = UIStoryboard(name: "symptomMain", bundle: nil)
        if let symptomsVC = storyboard.instantiateViewController(withIdentifier: "SymptomsViewController") as? SymptomsViewController {
            
            let navController = UINavigationController(rootViewController: symptomsVC)
            
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            
            present(navController, animated: true)
        }
    }
}
