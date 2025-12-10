//
//  BreathingViewController.swift
//  ChemoCompanion
//
//  Created by ChemoCompanion Dev on 28/11/25.
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
    
    // Track selected filter (Defaults to first one "All")
    var selectedFilterIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // A. Load Data
        favoriteSessions = dataManager.getFavoriteSessions()
        filterTags = dataManager.getFilterTags()
        allSessions = dataManager.getAllSessions()
        
        // B. Register Cells
        registerCells()
        
        // C. Setup Data Source (We will add the extension in Step 8)
        collectionView.dataSource = self
        
        // D. Setup Layout (We will add the function in Step 9)
        func generateLayout() -> UICollectionViewCompositionalLayout {
                return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
                    
                    // 1. Define the Header Size (Standard for all sections that use it)
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
                    
                    // ---------------------------------------------------------
                    // SECTION 0: FAVORITES (Large Horizontal Cards)
                    // ---------------------------------------------------------
                    if sectionIndex == 0 {
                        
                        // Item
                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                        
                        // Group (Width 75% of screen so you can see the next card peeking)
                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .absolute(320))
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        
                        // Section
                        let section = NSCollectionLayoutSection(group: group)
                        section.orthogonalScrollingBehavior = .groupPagingCentered // Snaps to center
                        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
                        
                        // Add Header
                        section.boundarySupplementaryItems = [header]
                        return section
                        
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
        
        
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        // NOTE: I commented this out so the app doesn't crash until we add the function in Step 9.
    }
    
    func registerCells() {
        // Section 0: Large Cards
        collectionView.register(UINib(nibName: "FavoriteSessionCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteCell")
        
        // Section 1: Filter Pills
        collectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        
        // Section 2: List Rows
        collectionView.register(UINib(nibName: "SessionListCell", bundle: nil), forCellWithReuseIdentifier: "ListCell")
        
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
            return favoriteSessions.count // Top Cards
        } else if section == 1 {
            return filterTags.count       // Filter Pills
        } else {
            return allSessions.count      // Vertical List
        }
    }
    
    // 3. Create the specific cell for each section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            // SECTION 0: FAVORITE CARDS
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteSessionCell
            cell.configureCell(session: favoriteSessions[indexPath.row])
            return cell
            
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
            cell.configureCell(session: allSessions[indexPath.row])
            return cell
        }
    }
    
    // 4. Create the Headers ("Favourites", "Explore Sessions")
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        
        if indexPath.section == 0 {
            header.configureHeader(text: "Favourites")
        } else if indexPath.section == 1 {
            header.configureHeader(text: "Explore Sessions")
        } else {
            header.configureHeader(text: "") // No header for the list part
        }
        
        return header
    }
}
