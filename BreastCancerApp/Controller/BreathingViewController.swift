//
//  BreathingViewController.swift
//
//  Created by Shloka on 28/11/25.
//
import UIKit

class BreathingViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataManager = BreathingDataManager()
    var favoriteSessions: [BreathingSession] = []
    var filterTags: [String] = []
    var allSessions: [BreathingSession] = []
    
    var filteredSessions: [BreathingSession] = []
    
    var selectedFilterIndex: Int = 0

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteSessions = dataManager.getFavoriteSessions()
        filterTags = dataManager.getFilterTags()
        allSessions = dataManager.getAllSessions()
        
        filteredSessions = allSessions
        registerCells()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: false) //apply compositional layout
    }
    
    // Layout Generation
    func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            header.extendsBoundary = true
      
            if sectionIndex == 0 {
                
                if self.favoriteSessions.isEmpty {
                    //  SMALL LAYOUT (For "No Favorites" Message)
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                    section.boundarySupplementaryItems = [header]
                    return section
                    
                } else {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .absolute(320))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .groupPagingCentered
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                    section.boundarySupplementaryItems = [header]
                    return section
                }
            }
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
    
    // Register Cells
    func registerCells() {
        collectionView.register(UINib(nibName: "FavoriteSessionCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteSessionCell")
        collectionView.register(UINib(nibName: "BreathingEmptyStateCell", bundle: nil), forCellWithReuseIdentifier: "BreathingEmptyStateCell")
   
        collectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        
        collectionView.register(UINib(nibName: "SessionListCell", bundle: nil), forCellWithReuseIdentifier: "ListCell")
        
        collectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "HeaderView")
    }
}

// Data Source
extension BreathingViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return favoriteSessions.isEmpty ? 1 : favoriteSessions.count
        } else if section == 1 {
            return filterTags.count
        } else {
            return filteredSessions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
    
            if favoriteSessions.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BreathingEmptyStateCell", for: indexPath) as! BreathingEmptyStateCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteSessionCell", for: indexPath) as! FavoriteSessionCell
                cell.delegate = self
                cell.configureCell(session: favoriteSessions[indexPath.row])
                return cell
            }
            
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
            let tagText = filterTags[indexPath.row]
            let isSelected = (indexPath.row == selectedFilterIndex)
            cell.configure(text: tagText, isSelected: isSelected)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! SessionListCell
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

// Filter Interaction Delegate
extension BreathingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
  
        else {
            var selectedSession: BreathingSession?
            
            if indexPath.section == 0 {
                if !favoriteSessions.isEmpty {
                    selectedSession = favoriteSessions[indexPath.row]
                }
            } else if indexPath.section == 2 {
                selectedSession = filteredSessions[indexPath.row]
            }
            
            if let session = selectedSession {
                
                let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
                if let playerVC = storyboard.instantiateViewController(withIdentifier: "BreathingPlayerVC") as? BreathingPlayerViewController {
                    
                    playerVC.session = session
                    
                    if let nav = self.navigationController {
                        nav.pushViewController(playerVC, animated: true)
                    } else {
                        playerVC.modalPresentationStyle = .fullScreen
                        self.present(playerVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

// Heart Button Delegate (Like/Unlike Logic)
extension BreathingViewController: SessionCellDelegate {
    
    func didTapLikeButton(on cell: UICollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        if indexPath.section == 0 {
            
            let sessionToRemove = favoriteSessions[indexPath.row]
            
            favoriteSessions.remove(at: indexPath.row)
            
            if let indexInMaster = allSessions.firstIndex(where: { $0.title == sessionToRemove.title }) {
                allSessions[indexInMaster].isFavorite = false
            }
            
            var indexInFiltered: Int? = nil
            if let index = filteredSessions.firstIndex(where: { $0.title == sessionToRemove.title }) {
                filteredSessions[index].isFavorite = false
                indexInFiltered = index
            }
            
            let isEmptyNow = favoriteSessions.isEmpty
            
            //  Update UI
            collectionView.performBatchUpdates {
                if let index = indexInFiltered {
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 2)])
                }
                
                if isEmptyNow {
                    collectionView.reloadSections(IndexSet(integer: 0))
                } else {
                    collectionView.deleteItems(at: [indexPath])
                }
                
            } completion: { _ in
                if isEmptyNow {
                    self.collectionView.setCollectionViewLayout(self.generateLayout(), animated: true)
                }
            }
        }
        
        else if indexPath.section == 2 {
            let session = filteredSessions[indexPath.row]

            BreathingFavoritesManager.toggleFavorite(
                session: session,
                allSessions: &allSessions,
                favorites: &favoriteSessions,
                filtered: &filteredSessions
            )
            collectionView.performBatchUpdates {
                collectionView.reloadSections(IndexSet(integer: 0))
                collectionView.reloadSections(IndexSet(integer: 2))
            }

        }
    }
}
