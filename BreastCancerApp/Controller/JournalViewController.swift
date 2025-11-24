//
//  JournalViewController.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import UIKit

class JournalViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    enum Section: Int, CaseIterable {
        case streak
        case stats
    }

    private var journalDataSource: JournalDataSource!

    // Replace with real data later
    private var entries: [JournalEntry] = SampleJournalData.recent
    private var streak: Int = 7
    private var thisWeekCount: Int = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGroupedBackground
        navigationItem.title = "Journal"
        collectionView.backgroundColor = UIColor.systemGroupedBackground


        setupCollectionView()

        journalDataSource = JournalDataSource(
            collectionView: collectionView,
            entries: entries,
            streak: streak,
            thisWeekCount: thisWeekCount
        )

        journalDataSource.applySnapshot()
    }
}

extension JournalViewController {

    private func setupCollectionView() {

        // MARK: Compositional Layout (ONLY Streak section)
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(120)
                ),
                subitems: [item]
            )
            group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

            return NSCollectionLayoutSection(group: group)
        }

        collectionView.setCollectionViewLayout(layout, animated: false)

        // MARK: Register XIB for Streak Cell
        collectionView.register(
            UINib(nibName: "JournalStreakCell", bundle: nil),
            forCellWithReuseIdentifier: JournalStreakCell.reuseIdentifier
        )
        
        collectionView.register(
            UINib(nibName: "JournalStatsCell", bundle: nil),
            forCellWithReuseIdentifier: JournalStatsCell.reuseIdentifier
        )

    }
}
