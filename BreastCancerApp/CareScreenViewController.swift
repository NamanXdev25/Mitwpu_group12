import UIKit

class CareScreenViewController: UIViewController {

    @IBOutlet weak var CareCollectionView: UICollectionView!
    
    // Expansion State
    var isHydrationExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        CareCollectionView.delegate = self
        CareCollectionView.dataSource = self
        
        // Set the Compositional Layout
        CareCollectionView.collectionViewLayout = createLayout()
        
        // Register all your XIBs - FIXED: Changed "HydrationCell" to "CareHydrationCell"
        let identifiers = [
            "CareHeaderCell", "CareHydrationCell", "CareMedicationCell",
            "CareDailyExerciseCell", "CareSymptomsCell",
            "CareAppointmentsCell", "CareViewInsightsCell"
        ]
        
        for id in identifiers {
            CareCollectionView.register(UINib(nibName: id, bundle: nil), forCellWithReuseIdentifier: id)
        }
    }
    
    // MARK: - Compositional Layout Setup
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            // REMOVED: Unused closure 'sectionProvider' that was causing the warning
            
            // Define item with estimated height
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            ))
            
            // Create group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            // Create section
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12 // Spacing between cards
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
            
            return section
        }
        
        return layout
    }
}

extension CareScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.item {
        case 0: // Today Header
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareHeaderCell", for: indexPath) as! CareHeaderCell
            cell.Titlelabel.text = "Today"
            cell.Managelabel.isHidden = true
            return cell
            
        case 1: // Hydration
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareHydrationCell", for: indexPath) as! CareHydrationCell
            cell.configure(isExpanded: isHydrationExpanded, progress: 0.66, currentAmount: "2/3 Ltr", goal: "3.0 L", cupSize: "200 mL")
            return cell
            
        case 2: // Medication
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareMedicationCell", for: indexPath) as! CareMedicationCell
            return cell
            
        case 3: // Exercise
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareDailyExerciseCell", for: indexPath) as! CareDailyExerciseCell
            return cell
            
        case 4: // Symptoms
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareSymptomsCell", for: indexPath) as! CareSymptomsCell
            cell.configure(title: "Symptoms logged", loggedSymptoms: ["Fatigue", "Nausea", "Pain", "+2"])
            return cell
            
        case 5: // Appointment Header
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareHeaderCell", for: indexPath) as! CareHeaderCell
            cell.Titlelabel.text = "Appointments"
            cell.Managelabel.isHidden = false
            return cell
            
        case 6: // Appointment Card
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareAppointmentsCell", for: indexPath) as! CareAppointmentsCell
            return cell
            
        default: // Health Insights
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareViewInsightsCell", for: indexPath) as! CareViewInsightsCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 1 { // Hydration
            isHydrationExpanded.toggle()
            
            // To animate the height change in Compositional Layout,
            // we invalidate the layout and call performBatchUpdates.
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }
}
