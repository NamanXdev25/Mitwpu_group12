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

        // IMPORTANT: capture index for toggling(cell has a closure)
        cell.onCircleTapped = { [weak self] in
            guard let self = self else { return }
            
            // toggle the value
            self.todaysMedications[indexPath.row].isTaken.toggle()
            
            // reload just this cell (smooth)
            self.collectionView.reloadItems(at: [indexPath])
        }

        return cell
    }


    // MARK: - Loads Header(can be used to set date dynamically)
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "med_header",
            for: indexPath
        ) as! MedicationHeaderView

        header.configure(with: "Sun 20 Apr")
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
            section.interGroupSpacing = 12   //  for the gap between the cells
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 8, leading: 8, bottom: 20, trailing: 8
            )


            return section
        }
    }
}
