//
//  MonthMemoriesViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 12/02/26.
//

import UIKit

final class MonthMemoriesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Data
    var memories: [Memory] = []
    var month: Int = 1
    var year: Int = 2024
    
    private let calendar = Calendar.current
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
}

// MARK: - Configuration
private extension MonthMemoriesViewController {
    
    func configureNavigationBar() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        if let date = calendar.date(from: components) {
            title = formatter.string(from: date)
        }
        
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.leftBarButtonItem = closeButton
    }
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        collectionView.register(
            UINib(nibName: "MonthMemoryCell", bundle: nil),
            forCellWithReuseIdentifier: "MonthMemoryCell"
        )
    }
}

// MARK: - Actions
private extension MonthMemoriesViewController {
    
    @objc func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Collection View
extension MonthMemoriesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        memories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MonthMemoryCell",
            for: indexPath
        ) as! MonthMemoryCell
        
        let memory = memories[indexPath.item]
        
        // Set width for self-sizing
        let width = collectionView.bounds.width - 32
        cell.contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        cell.configure(with: memory)
        
        return cell
    }
}
