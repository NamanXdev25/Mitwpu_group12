//
//  ExerciseDetailViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 08/12/25.
//

import UIKit

class ExerciseDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // --- VARIABLES ---
    // This is set by the previous screen (e.g., "Chest Mobility")
    var pageTitle: String = ""
    // This is loaded from JSON
    var sections: [DetailSectionData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Set Navigation Title
        self.title = pageTitle
       // self.view.backgroundColor = .systemGray6
        
        // 2. Setup Collection View
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear // Show light gray screen background
        
        // 3. Register Cells (Detail Cell and Section Header)
        collectionView.register(UINib(nibName: "DetailExerciseCell", bundle: nil), forCellWithReuseIdentifier: "DetailExerciseCell")
        collectionView.register(UINib(nibName: "SectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        // 4. Load Data
        loadData()
    }
    
    func loadData() {
        // Load the data based on the pageTitle key
        guard let url = Bundle.main.url(forResource: "exerciseDetails", withExtension: "json") else {
            print("Error: exerciseDetails.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let allData = try JSONDecoder().decode(ExerciseDatabase.self, from: data)
            
            // Filter: Get only the sections corresponding to the tapped card's title
            if let specificPageData = allData[pageTitle] {
                self.sections = specificPageData
            } else {
                print("No data found for category: \(pageTitle)")
                self.sections = []
            }
            
            collectionView.reloadData()
            
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }

    // --- LAYOUT ---
        func createLayout() -> UICollectionViewLayout {
            // 1. Item (The Card)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Use 0 leading/trailing here, we will control padding at the Section level
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
            
            // 2. Group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            // 3. Section
            let section = NSCollectionLayoutSection(group: group)
            
            // APPLY PADDING HERE: This moves BOTH the cards and the header together
            section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 20, bottom: 4, trailing: 20)
            
            // 4. Header (Title "Low Energy")
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            // HERE IS THE FIX: Force the Header to match the Item's 20px inset
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            section.boundarySupplementaryItems = [header]
            
            return UICollectionViewCompositionalLayout(section: section)
        }
    // --- DATA SOURCE ---
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailExerciseCell", for: indexPath) as! DetailExerciseCell
        let item = sections[indexPath.section].exercises[indexPath.row]
        
        // Configure Cell with image, title, subtitle, and time
        cell.configure(title: item.title, subtitle: item.subtitle, time: item.time, imageName: item.imageName)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
        
        // Set the Section Header Title (e.g., "Low Energy")
        header.titleLabel.text = sections[indexPath.section].title
        header.titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        header.titleLabel.textColor = .black
        
        return header
    }
    
    // Add to ExerciseDetailViewController.swift

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section].exercises[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        if let playerVC = storyboard.instantiateViewController(withIdentifier: "ExercisePlayerViewController") as? ExercisePlayerViewController {
            playerVC.exerciseData = item
            self.navigationController?.pushViewController(playerVC, animated: true)
        }
    }
}
