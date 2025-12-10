import UIKit

class MedicationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Data Source
    var todaysMedications: [Medication] = [
        Medication(name: "Pill 1", note: "Before Breakfast", time: "8:00 AM", isTaken: false),
        Medication(name: "Pill 2", note: "After Lunch", time: "1:00 PM", isTaken: false),
        Medication(name: "Pill 3", note: "Before Bed", time: "9:00 PM", isTaken: false)
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup Collection View
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 2. Apply the Layout with Swipe Actions
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    // MARK: - Navigation / Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addVC = segue.destination as? AddMedicationViewController {
            addVC.delegate = self
        }
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
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todaysMedications.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "med_item", for: indexPath) as? MedicationItemCell else {
            return UICollectionViewCell()
        }

        let med = todaysMedications[indexPath.row]
        cell.configureCell(with: med)

        // Handle the "Taken" circle tap
        cell.onCircleTapped = { [weak self] in
            guard let self = self else { return }
            
            // Safety check
            if indexPath.row < self.todaysMedications.count {
                self.todaysMedications[indexPath.row].isTaken.toggle()
                self.collectionView.reloadItems(at: [indexPath])
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
            
            header.configure(with: "Today's Plan")
            return header
        }
        return UICollectionReusableView()
    }

    // MARK: - Layout Generation (With Swipe Actions)
    // MARK: - Layout Generation (With Swipe Actions)
        func generateLayout() -> UICollectionViewLayout {
            
            // 1. Create List Configuration
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            config.headerMode = .supplementary
            
            // 2. Define Swipe Actions
            config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                
                // --- ACTION 1: DELETE (Red) ---
                let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                    self?.confirmDelete(at: indexPath, completion: completion)
                }
                deleteAction.image = UIImage(systemName: "trash.fill")
                deleteAction.backgroundColor = .systemRed

                // --- ACTION 2: EDIT (Blue) ---
                let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, completion in
                    
                    // [FIX STARTS HERE] ---------------------------------
                    // 1. Get the data for the row we swiped
                    let selectedMed = self?.todaysMedications[indexPath.row]
                    
                    // 2. Instantiate the Add Screen
                    // MAKE SURE your Storyboard ID for the pink screen is set to "AddMedicationViewController"
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let addVC = storyboard.instantiateViewController(withIdentifier: "AddMedicationViewController") as? AddMedicationViewController {
                        
                        // 3. Pass the data to the screen
                        addVC.medicationToEdit = selectedMed
                        addVC.indexToEdit = indexPath.row
                        addVC.delegate = self
                        
                        // 4. Present it
                        self?.present(addVC, animated: true)
                    }
                    // [FIX ENDS HERE] -----------------------------------
                    
                    completion(true) // Close swipe
                }
                editAction.image = UIImage(systemName: "pencil")
                editAction.backgroundColor = .systemBlue
                
                // 3. Combine Actions
                let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
                swipeConfig.performsFirstActionWithFullSwipe = true
                
                return swipeConfig
            }
            
            return UICollectionViewCompositionalLayout.list(using: config)
        }
    
    // MARK: - Helper: Delete Confirmation
    func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        
        let medName = todaysMedications[indexPath.row].name
        
        let alert = UIAlertController(
            title: "Delete Medication?",
            message: "Are you sure you want to delete '\(medName)'?",
            preferredStyle: .alert
        )
        
        // Delete Action
        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // 1. Remove Data
            self?.todaysMedications.remove(at: indexPath.row)
            
            // 2. Remove Row from Screen
            self?.collectionView.deleteItems(at: [indexPath])
            
            // 3. Tell swipe gesture it was successful
            completion(true)
        }
        
        // Cancel Action
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Tell swipe gesture we cancelled
            completion(false)
        }
        
        alert.addAction(deleteBtn)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true)
    }
}

// MARK: - AddMedicationDelegate Extension
extension MedicationViewController: AddMedicationDelegate {
    
    // Existing Add Function
    func didAddMedication(name: String, time: String, repeatOption: String, note: String) {
        let subtitle = note.isEmpty ? repeatOption : note
        let newPill = Medication(name: name, note: subtitle, time: time, isTaken: false)
        todaysMedications.append(newPill)
        collectionView.reloadData()
    }
    
    // NEW: Edit Function
    func didEditMedication(index: Int, name: String, time: String, repeatOption: String, note: String) {
        
        // 1. Create updated object
        let subtitle = note.isEmpty ? repeatOption : note
        let updatedPill = Medication(name: name, note: subtitle, time: time, isTaken: false)
        
        // 2. Replace the old one in the array
        todaysMedications[index] = updatedPill
        
        // 3. Reload just that row (efficient)
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
}
