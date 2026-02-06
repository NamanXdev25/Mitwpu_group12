//
//  StoreViewController.swift
//  healinggarden2
//
//  Created by Naman Bhansali on 27/01/26.
//

import UIKit

class StoreViewController: UIViewController {

    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    private let gardenManager = GardenManager.shared
    private var currentData: [StoreItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        updateData()
    }

    private func setupCollectionView() {
        storeCollectionView.dataSource = self
        storeCollectionView.delegate = self
        
        // Apply Compositional Layout
        storeCollectionView.setCollectionViewLayout(createLayout(), animated: false)
    }

    // MARK: - Compositional Layout Construction
    private func createLayout() -> UICollectionViewLayout {
        // 1. Item: Each cell takes up 50% of the group's width
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add spacing inside the item
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        // 2. Group: A horizontal row containing 2 items
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.65) // Aspect ratio for the card
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 3. Section: Container for groups
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateData()
    }
    
//    @IBAction func backButtonTapped(_ sender: UIButton) {
//        self.dismiss(animated: true)
//    }

    private func updateData() {
        let categories = ["Your Items", "Nature", "Wellness"]
        let selectedCategory = categories[categorySegmentedControl.selectedSegmentIndex]
        
        currentData = gardenManager.getItems(for: selectedCategory)
        storeCollectionView.reloadData()
    }
}

// MARK: - DataSource & Delegate
extension StoreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCell", for: indexPath) as! StoreItemCell
        cell.configure(with: currentData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = currentData[indexPath.item]
        
        if gardenManager.purchaseItem(item) {
            print("Purchased \(item.name)!")
            // Refresh if in the "Your Items" tab
            updateData()
        }
    }
}
