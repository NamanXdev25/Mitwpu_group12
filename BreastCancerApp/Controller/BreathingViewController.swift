//
//  BreathingViewController.swift
//  Created by Shloka on 28/11/2025
//
//

import UIKit

class BreathingViewController: UIViewController {

    // 1. Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 2. Data Variables
    var dataManager = BreathingDataManager()
    
    var favoriteSessions: [BreathingSession] = []
    var filterTags: [String] = []
    var allSessions: [BreathingSession] = []
    var filteredSessions: [BreathingSession] = []
    
    // Track selected filter (Defaults to first one "All")
    var selectedFilterIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // A. Load Data
        favoriteSessions = dataManager.getFavoriteSessions()
        filterTags = dataManager.getFilterTags()
        allSessions = dataManager.getAllSessions()
        
        //  INITIALIZE FILTERED LIST (Start by showing everything)
                filteredSessions = allSessions
        
        // B. Register Cells
        registerCells()
        
        // C. Setup Data Source (We will add the extension in Step 8)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        // NOTE: I commented this out so the app doesn't crash until we add the function in Step 9.
      
            }
        
        
        // D. Setup Layout (We will add the function in Step 9)
        func generateLayout() -> UICollectionViewCompositionalLayout {
                return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
                    
                    // 1. Define the Header Size (Standard for all sections that use it)
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
                    
                    // ---------------------------------------------------------
                    // SECTION 0: FAVORITES (Large Horizontal Cards)
                    // ---------------------------------------------------------
                    // ---------------------------------------------------------
                                // SECTION 0: FAVORITES
                                // ---------------------------------------------------------
                                if sectionIndex == 0 {
                                    
                                    // CHECK: Is the list empty?
                                    if self.favoriteSessions.isEmpty {
                                        // --- SMALL LAYOUT (For "No Favorites" Message) ---
                                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                                        
                                        // Height: 120 (Small and snug!)
                                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                                        
                                        let section = NSCollectionLayoutSection(group: group)
                                        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                                        section.boundarySupplementaryItems = [header]
                                        return section
                                        
                                    } else {
                                        // --- BIG LAYOUT (For Real Cards) ---
                                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                                        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                                        
                                        // Height: 320 (Big for images)
                                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .absolute(320))
                                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                                        
                                        let section = NSCollectionLayoutSection(group: group)
                                        section.orthogonalScrollingBehavior = .groupPagingCentered
                                        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
                                        section.boundarySupplementaryItems = [header]
                                        return section
                                    }
                                }
                    // ---------------------------------------------------------
                    // SECTION 1: FILTERS (Small Horizontal Pills)
                    // ---------------------------------------------------------
                    else if sectionIndex == 1 {
                        
                        // Item (Estimated Width allows pills to grow with text length)
                        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1.0))
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        
                        // Group
                        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
                        // Section
                        let section = NSCollectionLayoutSection(group: group)
                        section.orthogonalScrollingBehavior = .continuous // Smooth scrolling
                        section.interGroupSpacing = 10 // Space between pills
                        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                        
                        // Add Header ("Explore Sessions")
                        section.boundarySupplementaryItems = [header]
                        return section
                        
                    }
                    // ---------------------------------------------------------
                    // SECTION 2: LIST (Vertical Rows)
                    // ---------------------------------------------------------
                    else {
                        
                        // Item
                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
                        
                        // Group (Full Width, Fixed Height of 100 for list rows)
                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                        
                        // Section
                        let section = NSCollectionLayoutSection(group: group)
                        // No scrolling behavior needed (vertical is default)
                        
                        // No header for this section (The header is above the filters)
                        return section
                    }
                }
    }
    
    func registerCells() {
            // Section 0: Large Cards
            collectionView.register(UINib(nibName: "FavoriteSessionCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteSessionCell")
            
            // Section 1: Filter Pills
            collectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
            
            // Section 2: List Rows
            collectionView.register(UINib(nibName: "SessionListCell", bundle: nil), forCellWithReuseIdentifier: "ListCell")
            
            // --- ADD THIS LINE IF MISSING ---
            collectionView.register(UINib(nibName: "EmptyStateCell", bundle: nil), forCellWithReuseIdentifier: "EmptyStateCell")
            
            // Headers
            collectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "HeaderView")
        }
}

extension BreathingViewController: UICollectionViewDataSource {
    
    // 1. How many sections? We have 3.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    // 2. How many items in each section?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if section == 0 {
                return favoriteSessions.isEmpty ? 1 : favoriteSessions.count
            } else if section == 1 {
                return filterTags.count
            } else {
                // CHANGE THIS LINE:
                return filteredSessions.count
            }
        }
    
    // 3. Create the specific cell for each section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
                    
                    // CHECK: Is the list empty?
                    if favoriteSessions.isEmpty {
                        // Show the Empty Note
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyStateCell", for: indexPath) as! EmptyStateCell
                        return cell
                    } else {
                        // Show the Real Card
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteSessionCell", for: indexPath) as! FavoriteSessionCell
                        cell.delegate = self
                        cell.configureCell(session: favoriteSessions[indexPath.row])
                        return cell
                    }
                    
                } else if indexPath.section == 1 {
            // SECTION 1: FILTER PILLS
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
            let tagText = filterTags[indexPath.row]
            
            // Check if this specific button is the "Selected" one (Pink vs Gray)
            let isSelected = (indexPath.row == selectedFilterIndex)
            cell.configure(text: tagText, isSelected: isSelected)
            
            return cell
            
                } else {
                            // SECTION 2: LIST ROWS
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! SessionListCell
                            cell.delegate = self
                            
                            //  use filteredSessions:
                            cell.configureCell(session: filteredSessions[indexPath.row])
                            
                            return cell
                        }
    }
    
    // 4. Create the Headers ("Favourites", "Explore Sessions")
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
                
                if indexPath.section == 0 {
                    // CHANGED THIS: Always show "Favourites" now,
                    // because even if empty, we show the "No Favorites" box below it.
                    header.configureHeader(text: "Favourites")
                    
                } else if indexPath.section == 1 {
                    header.configureHeader(text: "Explore Sessions")
                } else {
                    header.configureHeader(text: "") // No header for the list part
                }
                
                return header
            }
}

extension BreathingViewController: SessionCellDelegate {
    
    func didTapLikeButton(on cell: UICollectionViewCell) {
            
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            
            // CASE A: Removing from Top Section (Favorites)
            if indexPath.section == 0 {
                
                let sessionToRemove = favoriteSessions[indexPath.row]
                
                // We need to find the matching item in the list to update its heart color later
                var indexInMainList: Int? = nil
                if let index = allSessions.firstIndex(where: { $0.title == sessionToRemove.title }) {
                    indexInMainList = index
                }
                
                // START THE BATCH UPDATE (Prevents the crash)
                collectionView.performBatchUpdates {
                    
                    // 1. Update the Data Arrays INSIDE the batch
                    favoriteSessions.remove(at: indexPath.row)
                    
                    if let mainIndex = indexInMainList {
                        allSessions[mainIndex].isFavorite = false
                        // Reload the list row immediately
                        collectionView.reloadItems(at: [IndexPath(item: mainIndex, section: 2)])
                    }
                    
                    // 2. Handle the Top Section UI
                    if favoriteSessions.isEmpty {
                        // Transition: Real Card -> Empty State Cell
                        // Since count is technically 1 -> 1 (Real -> Empty), we reload the section
                        collectionView.reloadSections(IndexSet(integer: 0))
                    } else {
                        // Normal deletion
                        collectionView.deleteItems(at: [indexPath])
                    }
                }
            }
            
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        // NOTE: I commented this out so the app doesn't crash until we add the function in Step 9.
            }
        }


extension BreathingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Check if the tap happened in the Filter Section (Section 1)
        if indexPath.section == 1 {
            
            // 1. Update the "Pink Pill" Selection variable
            selectedFilterIndex = indexPath.row
            
            // 2. Get the name of the selected filter (e.g., "Sleep")
            let selectedCategory = filterTags[indexPath.row]
            
            // 3. Perform the Filtering logic
            if selectedCategory == "All" {
                // If "All", show everything
                filteredSessions = allSessions
            } else {
                // Otherwise, search the master list for matches
                filteredSessions = allSessions.filter { session in
                    return session.category == selectedCategory
                }
            }
            
            // 4. Update the UI
            // We use performBatchUpdates for smooth animation
            collectionView.performBatchUpdates {
                // Reload Section 1 (to move the pink color to the new button)
                collectionView.reloadSections(IndexSet(integer: 1))
                
                // Reload Section 2 (to show the new filtered items)
                collectionView.reloadSections(IndexSet(integer: 2))
            }
        }
    }
}
