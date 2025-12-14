import UIKit

class MedicalLogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Basic Setup
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 2. CRITICAL: Make image go behind the Notch
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // 3. Register All XIBs (Included StatsRowCell)
        let cells = ["HeaderCell", "AppointmentCell", "StatsRowCell", "MedicationCell", "TrackingCell"]
        for cellName in cells {
            collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        }
        
        // 4. Register Header
        collectionView.register(UINib(nibName: "LogsSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LogsSectionHeader.identifier)
        
        // 5. Apply Layout
        collectionView.collectionViewLayout = createLayout()
    }
    
    // MARK: - Compositional Layout
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            
            // SECTION 0: Top Header
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                return section
            }
            
            // SECTION 1: Appointment Card
            else if sectionIndex == 1 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(110)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)
                return section
            }
            
            // SECTION 2: Grid Row (Using StatsRowCell)
            else if sectionIndex == 2 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(165)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)
                return section
            }
            
            // SECTION 3: Medications
            else if sectionIndex == 3 {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
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
                
                // --- SCROLLING FIX ---
                // Add 120pts of bottom padding. This pushes the content up so it sits
                // above the Home Indicator and future Tab Bar when scrolled to the bottom.
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 120, trailing: 0)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(34))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                return section
            }
        }
    }

    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 5 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 2 { return 1 } // StatsRowCell (1 row contains 2 cards)
        if section == 4 { return 2 }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCell.identifier, for: indexPath) as! HeaderCell
            cell.titleLabel.text = "Logs"
            cell.dateLabel.text = "Mon 20 Apr"
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppointmentCell.identifier, for: indexPath) as! AppointmentCell
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatsRowCell.identifier, for: indexPath) as! StatsRowCell
            cell.configure()
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MedicationCell.identifier, for: indexPath) as! MedicationCell
            cell.pillNameLabel.text = "Pill 2"
            cell.timeLabel.text = "2:00 PM"
            cell.instructionLabel.text = "After Lunch"
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackingCell.identifier, for: indexPath) as! TrackingCell
            let pinkColor = UIColor(red: 0.910, green: 0.416, blue: 0.573, alpha: 1.0)
            cell.iconImageView.tintColor = pinkColor
            
            if indexPath.row == 0 {
                cell.titleLabel.text = "Track Your Symptoms"
                cell.subtitleLabel.text = "Last: 2 Days ago"
                cell.iconImageView.image = UIImage(systemName: "list.clipboard")
            } else {
                cell.titleLabel.text = "Self-Exam Steps"
                cell.subtitleLabel.text = "Last: 23 Days ago"
                cell.iconImageView.image = UIImage(systemName: "heart")
            }
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LogsSectionHeader.identifier, for: indexPath) as! LogsSectionHeader
        
        if indexPath.section == 3 {
            header.configure(title: "Medications", showManage: true)
        } else if indexPath.section == 4 {
            header.configure(title: "Health Tracking", showManage: false)
        }
        return header
    }
}
