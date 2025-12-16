//
//  BreathingViewController.swift
//
//  Created by Shloka on 28/11/25.
//

import UIKit

class BreathingViewController: UIViewController {

    // 1. Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 2. Data Variables
    var dataManager = BreathingDataManager()
    
    // Lists
    var favoriteSessions: [BreathingSession] = []
    var filterTags: [String] = []
    
    // "Master" List (Database - Holds everything)
    var allSessions: [BreathingSession] = []
    
    // "Display" List (What users actually see based on filters)
    var filteredSessions: [BreathingSession] = []
    
    // Track selected filter (Defaults to first one "All")
    var selectedFilterIndex: Int = 0

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // A. Load Data
        favoriteSessions = dataManager.getFavoriteSessions()
        filterTags = dataManager.getFilterTags()
        allSessions = dataManager.getAllSessions()
        
        // Initialize Filtered List (Start by showing everything)
        filteredSessions = allSessions
        
        // B. Register Cells
        registerCells()
        
        // C. Setup Data Source & Delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // D. Setup Layout
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    
    // MARK: - Layout Generation
    // MOVED OUTSIDE viewDidLoad (Crucial Fix)
    func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            
            // Define the Header Size
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            header.extendsBoundary = true
      
            // SECTION 0: FAVORITES
            if sectionIndex == 0 {
                
                // CHECK: Is the list empty?
                if self.favoriteSessions.isEmpty {
                    //  SMALL LAYOUT (For "No Favorites" Message)
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    // Height: 120 (Small and snug)
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
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                    section.boundarySupplementaryItems = [header]
                    return section
                }
            }
          
            // SECTION 1: FILTERS
            else if sectionIndex == 1 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                section.boundarySupplementaryItems = [header]
                return section
                
            }
            
            // SECTION 2: LIST
            else {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
    }
    
    // MARK: - Register Cells
    func registerCells() {
        // Section 0
        collectionView.register(UINib(nibName: "FavoriteSessionCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteSessionCell")
        collectionView.register(UINib(nibName: "EmptyStateCell", bundle: nil), forCellWithReuseIdentifier: "EmptyStateCell")
        
        // Section 1
        collectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        
        // Section 2
        collectionView.register(UINib(nibName: "SessionListCell", bundle: nil), forCellWithReuseIdentifier: "ListCell")
        
        // Headers
        collectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "HeaderView")
    }
}

// MARK: - Data Source
extension BreathingViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // Logic: If empty, show 1 "No Favorites" cell. Else show real count.
            return favoriteSessions.isEmpty ? 1 : favoriteSessions.count
        } else if section == 1 {
            return filterTags.count
        } else {
            return filteredSessions.count // Use Filtered List
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            // SECTION 0: FAVORITES
            if favoriteSessions.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyStateCell", for: indexPath) as! EmptyStateCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteSessionCell", for: indexPath) as! FavoriteSessionCell
                // Wire up Delegate
                cell.delegate = self
                cell.configureCell(session: favoriteSessions[indexPath.row])
                return cell
            }
            
        } else if indexPath.section == 1 {
            // SECTION 1: FILTERS
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
            let tagText = filterTags[indexPath.row]
            let isSelected = (indexPath.row == selectedFilterIndex)
            cell.configure(text: tagText, isSelected: isSelected)
            return cell
            
        } else {
            // SECTION 2: LIST
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! SessionListCell
            // Wire up Delegate
            cell.delegate = self
            cell.configureCell(session: filteredSessions[indexPath.row]) // Use Filtered List
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        
        if indexPath.section == 0 {
            header.configureHeader(text: "Favourites")
        } else if indexPath.section == 1 {
            header.configureHeader(text: "Explore Sessions")
        } else {
            header.configureHeader(text: "")
        }
        
        return header
    }
}

// MARK: - Filter Interaction Delegate
extension BreathingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // SECTION 1: FILTERS (Existing Logic)
        if indexPath.section == 1 {
            selectedFilterIndex = indexPath.row
            let selectedCategory = filterTags[indexPath.row]
            
            filteredSessions = BreathingSessionFilter.apply(
                sessions: allSessions,
                category: selectedCategory
            )

            collectionView.performBatchUpdates {
                collectionView.reloadSections(IndexSet(integer: 1))
                collectionView.reloadSections(IndexSet(integer: 2))
            }
        }
 
        // SECTION 0 & 2: NAVIGATION (New Logic)
  
        else {
            // 1. Figure out which session was tapped
            var selectedSession: BreathingSession?
            
            if indexPath.section == 0 {
                // Favorites Section
                // Safety check: Don't click the "No Favorites" placeholder
                if !favoriteSessions.isEmpty {
                    selectedSession = favoriteSessions[indexPath.row]
                }
            } else if indexPath.section == 2 {
                // List Section
                selectedSession = filteredSessions[indexPath.row]
            }
            
            // 2. Perform Navigation if we found a session
            if let session = selectedSession {
                
                // A. Load the Player Screen from Storyboard
                let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
                if let playerVC = storyboard.instantiateViewController(withIdentifier: "BreathingPlayerVC") as? BreathingPlayerViewController {
                    
                    // B. Pass the Data
                    playerVC.session = session
                    
                    // C. Show the Screen
                    // If we are inside a Navigation Controller, push it (Slide animation)
                    if let nav = self.navigationController {
                        nav.pushViewController(playerVC, animated: true)
                    } else {
                        // Otherwise, present it modally (Pop up from bottom)
                        playerVC.modalPresentationStyle = .fullScreen
                        self.present(playerVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

// MARK: - Heart Button Delegate (Like/Unlike Logic)
extension BreathingViewController: SessionCellDelegate {
    
    func didTapLikeButton(on cell: UICollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        // CASE A: Removing from Favorites (Top Section)
        if indexPath.section == 0 {
            
            let sessionToRemove = favoriteSessions[indexPath.row]
            
            // 1. Remove from Favorites
            favoriteSessions.remove(at: indexPath.row)
            
            // 2. Sync with Master List (Un-like in database)
            if let indexInMaster = allSessions.firstIndex(where: { $0.title == sessionToRemove.title }) {
                allSessions[indexInMaster].isFavorite = false
            }
            
            // 3. Sync with Filtered List (Un-like on screen so heart turns gray)
            var indexInFiltered: Int? = nil
            if let index = filteredSessions.firstIndex(where: { $0.title == sessionToRemove.title }) {
                filteredSessions[index].isFavorite = false
                indexInFiltered = index
            }
            
            let isEmptyNow = favoriteSessions.isEmpty
            
            // 4. Update UI
            collectionView.performBatchUpdates {
                // Update heart color in list below
                if let index = indexInFiltered {
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 2)])
                }
                
                if isEmptyNow {
                    // Transition: Real -> Empty (Swap Box)
                    collectionView.reloadSections(IndexSet(integer: 0))
                } else {
                    // Normal delete
                    collectionView.deleteItems(at: [indexPath])
                }
                
            } completion: { _ in
                // 5. Safe Layout Resize (After animation)
                if isEmptyNow {
                    self.collectionView.setCollectionViewLayout(self.generateLayout(), animated: true)
                }
            }
        }
        
        // CASE B: Tapping inside Main List (Section 2)
        else if indexPath.section == 2 {
            let session = filteredSessions[indexPath.row]

            BreathingFavoritesManager.toggleFavorite(
                session: session,
                allSessions: &allSessions,
                favorites: &favoriteSessions,
                filtered: &filteredSessions
            )
            collectionView.performBatchUpdates {
                collectionView.reloadSections(IndexSet(integer: 0)) // Favorites
                collectionView.reloadSections(IndexSet(integer: 2)) // List
            }

        }
    }
}
