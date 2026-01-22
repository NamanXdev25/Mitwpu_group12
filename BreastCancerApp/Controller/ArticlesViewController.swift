//
//  ArticlesViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 10/01/26.
//

import UIKit

class ArticlesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let dataSource = ArticlesDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Articles"
        setupCollectionView()
        dataSource.loadArticles()
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        // compositional layout
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        let nib = UINib(nibName: "ArticleCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ArticleCell")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(270)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(270)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 16
            )
            
            return section
        }
        
        return layout
    }
}

extension ArticlesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = dataSource.article(at: indexPath)

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "ArticleDetailViewController"
        ) as! ArticleDetailViewController

        vc.article = article
        
        // for modal presentation
        let navController = UINavigationController(rootViewController: vc)
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(navController, animated: true)
    }
}
