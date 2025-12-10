import UIKit

class MedicationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    // SAMPLE DATA
    var todaysMedications: [Medication] = [
        Medication(name: "Pill 1", note: "Before Breakfast", time: "8:00 AM", isTaken: false),
        Medication(name: "Pill 2", note: "After Lunch", time: "1:00 PM", isTaken: false),
        Medication(name: "Pill 3", note: "Before Bed", time: "9:00 PM", isTaken: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()

        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - 1. Prepare for Segue (The Connection)
    // This function runs automatically when you click the Pink "+" Button
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // We check if the destination is the Add Screen
        if let addVC = segue.destination as? AddMedicationViewController {
            // We tell the Add Screen: "I am your boss. Report back to me."
            addVC.delegate = self
        }
    }

    // MARK: - Register Cell + Header XIBs
    func registerCells() {
        // Medication Row Cell
        collectionView.register(
            UINib(nibName: "MedicationItemCell", bundle: nil),
            forCellWithReuseIdentifier: "med_item"
        )

        // Header
        collectionView.register(
            UINib(nibName: "MedicationHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "med_header"
        )
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1   // Only 1 section for today's meds
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todaysMedications.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "med_item",
            for: indexPath
        ) as! MedicationItemCell

        let med = todaysMedications[indexPath.row]
        cell.configureCell(with: med)

        // IMPORTANT: capture index for toggling (cell has a closure)
        cell.onCircleTapped = { [weak self] in
            guard let self = self else { return }
            
            // toggle the value
            self.todaysMedications[indexPath.row].isTaken.toggle()
            
            // reload just this cell (smooth)
            self.collectionView.reloadItems(at: [indexPath])
        }

        return cell
    }


    // MARK: - Loads Header
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "med_header",
            for: indexPath
        ) as! MedicationHeaderView

        header.configure(with: "Thur 27 Nov")
        return header
    }

    // MARK: - Compositional Layout
    func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env in

            // ---- HEADER ----
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )

            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            // ---- CELL ITEM ----
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // ---- GROUP ----
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            // ---- SECTION ----
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [headerItem]
            section.interGroupSpacing = 12   //  gap between cells
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 8, leading: 8, bottom: 20, trailing: 8
            )

            return section
        }
    }
}

// MARK: - 2. Handle the New Data (The Delegate)
// This adds the functionality to receive the data from the other screen
extension MedicationViewController: AddMedicationDelegate {
    
    func didAddMedication(name: String, time: String, repeatOption: String, note: String) {
        
        // 1. Create a new Medication object
        // (If the user didn't write a note, we use the repeat option as the subtitle, e.g. "Every Day")
        let subtitle = note.isEmpty ? repeatOption : note
        
        let newPill = Medication(name: name, note: subtitle, time: time, isTaken: false)
        
        // 2. Add it to our list
        todaysMedications.append(newPill)
        
        // 3. Refresh the screen to show the new pill
        collectionView.reloadData()
    }
}
