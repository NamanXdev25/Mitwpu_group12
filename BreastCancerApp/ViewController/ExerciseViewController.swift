//
//  ExerciseViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 26/11/25.
//

import UIKit

class ExerciseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AddExerciseDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var floatingAddButton: UIButton!
    @IBOutlet weak var calendarBarButton: UIBarButtonItem! // NEW: Calendar Bar Button
    
    var model = ExerciseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Layout
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register Cells
        registerCells()
        
        // Style Floating Button
//        floatingAddButton.layer.cornerRadius = floatingAddButton.frame.height / 2
//        floatingAddButton.layer.shadowColor = UIColor.black.cgColor
//        floatingAddButton.layer.shadowOpacity = 0.3
//        floatingAddButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        
    }
    
    func registerCells() {
        // Headers
        let headerNib = UINib(nibName: "SectionHeaderView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        // Cells
        collectionView.register(UINib(nibName: "PlanCell", bundle: nil), forCellWithReuseIdentifier: "PlanCell")
        collectionView.register(UINib(nibName: "WarningCell", bundle: nil), forCellWithReuseIdentifier: "WarningCell")
        // Using ExploreCell for the bottom list
        collectionView.register(UINib(nibName: "ExerciseExploreCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseExploreCell")
    }

    // --- COMPOSITIONAL LAYOUT ---
    func createLayout() -> UICollectionViewLayout {
        // IMPORTANT: We pass 'env' to use it for the List Section configuration
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createListSection(layoutEnvironment: env) // Modified to allow Swipes
            case 1: return self.createWarningSection() // Warning Banner
            default: return self.createExploreSection() // Explore Cards
            }
        }
    }
    
    // Section 0: Today's Plan (Updated to List Configuration)
    // This looks identical to the previous version but enables Swipe Actions
    func createListSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        // 1. Create a "Plain" list config
        // "Plain" allows us to maintain our custom white card look without the system forcing grouping styles.
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        
        // 2. Remove default system separators and backgrounds
        configuration.showsSeparators = false
        configuration.backgroundColor = .clear
        
        // 3. Define the Swipe Actions
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            return self?.swipeActions(for: indexPath)
        }
        
        // 4. Create the Section
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        
        // FIX: Remove interGroupSpacing so cells touch and form "One Big Card"
        // section.interGroupSpacing = 10  <-- REMOVED
        
        // 5. Apply the EXACT same insets as before to keep layout identical
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20)
        
        // FIX 2: Manually Configure Header for Alignment
        // List sections can sometimes ignore 'followsContentInsets' depending on configuration.
        // We manually create the header and force the padding to match the section (20).
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        // Disable automatic following and set manual insets to ensure it aligns with "Explore"
        section.supplementariesFollowContentInsets = false
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // --- NEW: Handle Swipe Actions ---
    func swipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 1. Get the item
        let item = model.todaysPlan[indexPath.row]
        
        // 2. DELETE Action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            // Remove from data source
            self.model.removeExercisesById(item.id)
            
            // Remove from UI
            self.collectionView.deleteItems(at: [indexPath])
            
            // Force reload section slightly later to re-calculate corner rounding (Top/Bottom corners)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
            
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        // 3. EDIT Action
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            // Open Edit Screen
            self.openEditScreen(for: item)
            
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue // Or UIColor(red: 0.85, green: 0.4, blue: 0.5, alpha: 1.0)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func openEditScreen(for item: PlanItem) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        
        // Load the Navigation Controller that contains AddExerciseViewController
        if let addNavController = storyboard.instantiateViewController(withIdentifier: "AddExercisenav") as? UINavigationController {
            
            // Get the AddExerciseViewController from the navigation controller
            if let addVC = addNavController.viewControllers.first as? AddExerciseViewController {
                
                addVC.delegate = self
                
                // PASS DATA TO PREFILL
                addVC.initialID = item.id
                addVC.initialName = item.title
                addVC.initialSubtitle = item.subtitle
                addVC.initialTime = item.time
                addVC.initialDescription = item.description // --- NEW: Pass description
            }
            
            // Present the navigation controller modally
            addNavController.modalPresentationStyle = .pageSheet
            if let sheet = addNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(addNavController, animated: true, completion: nil)
        }
    }
    
    // Section 1: Warning Banner
    func createWarningSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 15, trailing: 20)
        
        addHeader(to: section) // "Explore" Header
        return section
    }
    
    // Section 2: Explore Cards (Small Squares)
    func createExploreSection() -> NSCollectionLayoutSection {
        // 120x120 Squares
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
        // --- UPDATED LOGIC FOR EDITING ---
        // Check if this item ID already exists. If so, update it in place.
        // If not, add it to the top.
        
        if let index = model.todaysPlan.firstIndex(where: { $0.id == exercise.id }) {
            // Update existing (Edit Mode)
            model.todaysPlan[index] = exercise
            model.saveTodaysPlan()
        } else {
            // Add new (Create Mode)
            model.addPlanItem(exercise)
        }
        
        // Refresh the specific section (Today's Plan is Section 0)
        collectionView.reloadSections(IndexSet(integer: 0))
    }

    // --- UPDATED FLOATING BUTTON ACTION ---
    @IBAction func floatingButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        
        // Load the Navigation Controller that contains AddExerciseViewController
        if let addNavController = storyboard.instantiateViewController(withIdentifier: "AddExercisenav") as? UINavigationController {
            
            // Get the AddExerciseViewController from the navigation controller
            if let addVC = addNavController.viewControllers.first as? AddExerciseViewController {
                // IMPORTANT: Set the delegate so we can get data back!
                addVC.delegate = self
            }
            
            // Present the navigation controller modally
            addNavController.modalPresentationStyle = .pageSheet
            if let sheet = addNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(addNavController, animated: true, completion: nil)
        }
    }
    
    // --- NEW: CALENDAR BAR BUTTON ACTION ---
    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        
        // Load the Navigation Controller (not the CalendarViewController directly)
        if let calendarNavController = storyboard.instantiateViewController(withIdentifier: "ExerciseCalendarnav") as? UINavigationController {
            
            // Present the navigation controller modally
            calendarNavController.modalPresentationStyle = .pageSheet
            
            // Optional: Configure sheet size
            if let sheet = calendarNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(calendarNavController, animated: true, completion: nil)
        }
    }

    // --- DATA SOURCE ---
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return model.todaysPlan.count
        case 1: return 1 // Warning
        default: return model.exploreItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            // --- Today's Plan ---
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlanCell", for: indexPath) as! PlanCell
            let item = model.todaysPlan[indexPath.row]
            
            // Configure with new fields
            cell.configure(with: item)
            
            // Single Card Logic (Rounding Corners)
            // NOTE: We keep this logic because we are using a "Plain" list which doesn't auto-group
            let totalRows = collectionView.numberOfItems(inSection: 0)
            
            // Reset defaults
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
            
            // Handle Check Toggle
            cell.onToggle = { [weak self] in
                self?.model.togglePlanItem(at: indexPath.row)
                self?.collectionView.reloadItems(at: [indexPath])
            }
            
            // Handle Chevron Navigation
            cell.onNavigate = {
                print("Navigate to details for: \(item.title)")
            }
            
            return cell
            
        case 1:
            // --- Warning Banner ---
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WarningCell", for: indexPath) as! WarningCell
            return cell
            
        default:
            // --- Explore Cards (Small Squares) ---
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseExploreCell", for: indexPath) as! ExerciseExploreCell
            let item = model.exploreItems[indexPath.row]
            
            // Using String name for SF Symbols or Assets
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
        
        // --- NEW: Section 0 Selection (Show Description) ---
        if indexPath.section == 0 {
            let item = model.todaysPlan[indexPath.row]
            // Show Alert with Description
            let descriptionContent = (item.description != nil && !item.description!.isEmpty) ? item.description! : "No description available."
            let message = "Description: \(descriptionContent)"
            
            let alert = UIAlertController(title: item.title, message: message, preferredStyle: .alert)
            // Changed style to .destructive to make button red
            alert.addAction(UIAlertAction(title: "Close", style: .destructive))
            self.present(alert, animated: true)
        }
        
        // 1. Check if the tap is in the "Explore" section (Section 2)
        // (Section 0 is Plan, Section 1 is Warning, Section 2 is Explore Cards)
        else if indexPath.section == 2 {
            
            // 2. Get the data for the item that was tapped
            let item = model.exploreItems[indexPath.row]
            
            // 3. Load the Storyboard
            let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
            
            // 4. Create the Detail Screen
            // Make sure the Storyboard ID is set to "ExerciseDetailViewController"
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ExerciseDetailViewController") as? ExerciseDetailViewController {
                
                // 5. PASS THE DATA (This sets the Title!)
                detailVC.pageTitle = item.title
                
                // 6. Navigate
                // This pushes the new screen onto the stack.
                // The "Back" button is created automatically by the Navigation Controller.
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadSections(IndexSet(integer: 0))
    }

    
}
