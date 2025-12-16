import UIKit

class ExerciseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AddExerciseDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var floatingAddButton: UIButton!
    @IBOutlet weak var calendarBarButton: UIBarButtonItem!
    
    var model = ExerciseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Layout
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register Cells
        registerCells()
    }
    
    func registerCells() {
        let headerNib = UINib(nibName: "SectionHeaderView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        collectionView.register(UINib(nibName: "PlanCell", bundle: nil), forCellWithReuseIdentifier: "PlanCell")
        collectionView.register(UINib(nibName: "WarningCell", bundle: nil), forCellWithReuseIdentifier: "WarningCell")
        collectionView.register(UINib(nibName: "ExerciseExploreCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseExploreCell")
    }

    // --- COMPOSITIONAL LAYOUT ---
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createListSection(layoutEnvironment: env)
            case 1: return self.createWarningSection()
            default: return self.createExploreSection()
            }
        }
    }
    
    func createListSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        configuration.backgroundColor = .clear
        
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            return self?.swipeActions(for: indexPath)
        }
        
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.supplementariesFollowContentInsets = false
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    func swipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = model.currentDayPlan[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            self.model.removeExercisesById(item.id)
            self.collectionView.deleteItems(at: [indexPath])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            self.openEditScreen(for: item)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func openEditScreen(for item: PlanItem) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        
        if let addNavController = storyboard.instantiateViewController(withIdentifier: "AddExercisenav") as? UINavigationController {
            
            if let addVC = addNavController.viewControllers.first as? AddExerciseViewController {
                
                addVC.delegate = self
                addVC.initialID = item.id
                addVC.initialName = item.title
                addVC.initialSubtitle = item.subtitle
                addVC.initialTime = item.time
                addVC.initialDescription = item.description
                
                // --- NEW LOGIC: Lock name if it's a Library Exercise ---
                // 1. If ID is a UUID (standard format), it was likely created by the user -> EDITABLE.
                // 2. If ID is anything else (e.g. "chest_wallclimb_001"), it is from the Library -> LOCKED.
                
                if isUUID(item.id) {
                    addVC.isNameEditable = true // Custom
                } else {
                    addVC.isNameEditable = false // Library/Pre-loaded
                }
            }
            
            addNavController.modalPresentationStyle = .pageSheet
            if let sheet = addNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(addNavController, animated: true, completion: nil)
        }
    }
    
    // Helper to check if string is a UUID
    func isUUID(_ id: String) -> Bool {
        return UUID(uuidString: id) != nil
    }
    
    func createWarningSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 15, trailing: 20)
        addHeader(to: section)
        return section
    }
    
    func createExploreSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(220))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(220))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 40, trailing: 20)
        return section
    }
    
    func addHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
    }
    
    func didAddExercise(_ exercise: PlanItem) {
        if let index = model.todaysPlan.firstIndex(where: { $0.id == exercise.id }) {
            model.todaysPlan[index] = exercise
            model.saveTodaysPlan()
        } else {
            model.addPlanItem(exercise)
        }
        collectionView.reloadSections(IndexSet(integer: 0))
    }

    @IBAction func floatingButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        if let addNavController = storyboard.instantiateViewController(withIdentifier: "AddExercisenav") as? UINavigationController {
            if let addVC = addNavController.viewControllers.first as? AddExerciseViewController {
                addVC.delegate = self
                // Custom add -> Editable Name (Default is true)
            }
            addNavController.modalPresentationStyle = .pageSheet
            if let sheet = addNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            self.present(addNavController, animated: true, completion: nil)
        }
    }
    
    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        if let calendarNavController = storyboard.instantiateViewController(withIdentifier: "ExerciseCalendarnav") as? UINavigationController {
            calendarNavController.modalPresentationStyle = .pageSheet
            if let sheet = calendarNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            self.present(calendarNavController, animated: true, completion: nil)
        }
    }

    // --- DATA SOURCE ---
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 3 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return model.currentDayPlan.count
        case 1: return 1
        default: return model.exploreItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlanCell", for: indexPath) as! PlanCell
            let item = model.currentDayPlan[indexPath.row]
            cell.configure(with: item)
            
            let totalRows = collectionView.numberOfItems(inSection: 0)
            cell.containerView.layer.cornerRadius = 0
            cell.containerView.layer.maskedCorners = []
            cell.separatorView?.isHidden = false
            
            if totalRows == 1 {
                cell.containerView.layer.cornerRadius = 16
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorView?.isHidden = true
            } else if indexPath.row == 0 {
                cell.containerView.layer.cornerRadius = 16
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == totalRows - 1 {
                cell.containerView.layer.cornerRadius = 16
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorView?.isHidden = true
            }
            
            cell.onToggle = { [weak self] in
                self?.model.togglePlanItem(id: item.id)
                self?.collectionView.reloadItems(at: [indexPath])
            }
            
            cell.onNavigate = {
                print("Navigate to details for: \(item.title)")
            }
            
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WarningCell", for: indexPath) as! WarningCell
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseExploreCell", for: indexPath) as! ExerciseExploreCell
            let item = model.exploreItems[indexPath.row]
            cell.setup(title: item.title, imageName: item.imageName)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
        header.titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        header.titleLabel.textColor = .black
        
        switch indexPath.section {
        case 0: header.titleLabel.text = "Today's Plan"
        case 1: header.titleLabel.text = "Explore"
        default: header.titleLabel.text = ""
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let item = model.currentDayPlan[indexPath.row]
            let descriptionContent = (item.description != nil && !item.description!.isEmpty) ? item.description! : "No description available."
            let message = "Description: \(descriptionContent)"
            let alert = UIAlertController(title: item.title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .destructive))
            self.present(alert, animated: true)
        }
        else if indexPath.section == 2 {
            let item = model.exploreItems[indexPath.row]
            let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ExerciseDetailViewController") as? ExerciseDetailViewController {
                detailVC.pageTitle = item.title
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}
