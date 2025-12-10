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
    
    var model = ExerciseManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Layout
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register Cells
        registerCells()
        
        // Style Floating Button
        floatingAddButton.layer.cornerRadius = floatingAddButton.frame.height / 2
        floatingAddButton.layer.shadowColor = UIColor.black.cgColor
        floatingAddButton.layer.shadowOpacity = 0.3
        floatingAddButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // --- NEW: Add Calendar Button to Navigation Bar ---
        setupNavigationBar()
    }
    
    // --- NEW FUNCTION: Setup Navigation Bar ---
    func setupNavigationBar() {
        // 1. Set Title
        self.title = "Exercises"
        
        // 2. Create a Custom Button View
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        // 3. Configure Icon (Calendar with +)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(systemName: "calendar.badge.plus", withConfiguration: config)
        
        button.setImage(image, for: .normal)
        
        // 4. Style the Circle
       // button.backgroundColor = .systemGray6 // Light gray background
        button.tintColor = .black             // Black icon color
        button.layer.cornerRadius = 20        // Half of height (40) makes it a circle
        
        // 5. Add Action
        button.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        // 6. Set as Right Bar Item
        let barItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barItem
    }
    
    // --- CALENDAR ACTION ---
        @objc func calendarButtonTapped() {
               let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
               
               // Ensure Identifier "CalendarViewController" matches Storyboard ID
               if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
                   
                   // This makes it slide up as a card (default behavior)
                   if let sheet = calendarVC.sheetPresentationController {
                      // sheet.detents = [.medium(), .large()] // Allows it to be half or full screen
                       sheet.prefersGrabberVisible = true
                   }
                   
                   self.present(calendarVC, animated: true, completion: nil)
               }
           }
    
    
    func registerCells() {
        // Headers
        let headerNib = UINib(nibName: "SectionHeaderView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        // Cells
        collectionView.register(UINib(nibName: "PlanCell", bundle: nil), forCellWithReuseIdentifier: "PlanCell")
        collectionView.register(UINib(nibName: "WarningCell", bundle: nil), forCellWithReuseIdentifier: "WarningCell")
        // Using ExploreCell for the bottom list
        collectionView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "ExploreCell")
    }

    // --- COMPOSITIONAL LAYOUT ---
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createListSection()    // Today's Plan
            case 1: return self.createWarningSection() // Warning Banner
            default: return self.createExploreSection() // Explore Cards
            }
        }
    }
    
    // Section 0: Today's Plan (Vertical List)
    func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // No spacing between items to make it look like one card
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20)
        
        addHeader(to: section)
        return section
    }
    
    // Section 1: Warning Banner
    func createWarningSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 15, trailing: 20)
        
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
        // Add to model
        model.addPlanItem(exercise)
        
        // Refresh the specific section (Today's Plan is Section 0)
        collectionView.reloadSections(IndexSet(integer: 0))
    }

    // --- UPDATED FLOATING BUTTON ACTION ---
    @IBAction func floatingButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddExerciseViewController") as? AddExerciseViewController {
            
            // IMPORTANT: Set the delegate so we can get data back!
            addVC.delegate = self
            
            addVC.modalPresentationStyle = .pageSheet
            if let sheet = addVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(addVC, animated: true, completion: nil)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCell", for: indexPath) as! ExploreCell
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
        
        // 1. Check if the tap is in the "Explore" section (Section 2)
        // (Section 0 is Plan, Section 1 is Warning, Section 2 is Explore Cards)
        if indexPath.section == 2 {
            
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
    
    }

