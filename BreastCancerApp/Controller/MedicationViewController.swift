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

    // MARK: - Navigation
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

    // MARK: - Layout Generation (With Edit & Delete)
    func generateLayout() -> UICollectionViewLayout {
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.headerMode = .supplementary
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            
            // --- ACTION 1: DELETE (Red) ---
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                self?.confirmDelete(at: indexPath, completion: completion)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = .systemRed

            // --- ACTION 2: EDIT (Blue) ---
            let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, completion in
                
                // 1. Check if we can find the Storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                // 2. Try to find the View Controller safely
                // This ID ("AddMedicationViewController") MUST match what you typed in Step 1
                if let addVC = storyboard.instantiateViewController(withIdentifier: "AddMedicationViewController") as? AddMedicationViewController {
                    
                    // 3. Pass data
                    let selectedMed = self?.todaysMedications[indexPath.row]
                    addVC.medicationToEdit = selectedMed
                    addVC.indexToEdit = indexPath.row
                    addVC.delegate = self
                    
                    // 4. Open Screen
                    self?.present(addVC, animated: true)
                    
                } else {
                    print("ERROR: Could not find 'AddMedicationViewController' in Storyboard.")
                }
                
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
    func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        
        let medName = todaysMedications[indexPath.row].name
        
        let alert = UIAlertController(
            title: "Delete Medication?",
            message: "Are you sure you want to delete '\(medName)'?",
            preferredStyle: .alert
        )
        
        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.todaysMedications.remove(at: indexPath.row)
            self?.collectionView.deleteItems(at: [indexPath])
            completion(true)
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        
        alert.addAction(deleteBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true)
    }
}

// MARK: - Delegate Extension
extension MedicationViewController: AddMedicationDelegate {
    
    // Add New
    func didAddMedication(name: String, time: String, repeatOption: String, note: String) {
        let subtitle = note.isEmpty ? repeatOption : note
        let newPill = Medication(name: name, note: subtitle, time: time, isTaken: false)
        todaysMedications.append(newPill)
        collectionView.reloadData()
    }
    
    // Edit Existing
    // NOTE: This now uses 'index' instead of 'id' to be consistent.
    // Make sure your AddMedicationViewController protocol says 'index' too!
    func didEditMedication(index: Int, name: String, time: String, repeatOption: String, note: String) {
        
        let subtitle = note.isEmpty ? repeatOption : note
        let updatedPill = Medication(name: name, note: subtitle, time: time, isTaken: false)
        
        todaysMedications[index] = updatedPill
        
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
}

