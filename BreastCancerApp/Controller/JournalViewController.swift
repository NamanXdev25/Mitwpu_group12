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
        case actions
        case recents
    }

    private var journalDataSource: JournalDataSource!

    // Replace with real data later
    private var entries: [JournalEntry] = SampleJournalData.recent
    private var streak: Int = 7
    private var thisWeekCount: Int = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "Journal"
        collectionView.backgroundColor = UIColor(named: "BackgroundColor")

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

        // MARK: Compositional Layout for All Sections
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {

            // -----------------------
            // 1️⃣ STREAK
            // -----------------------
            case .streak:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(120)
                    ),
                    subitems: [item]
                )

                group.contentInsets = .init(top: 8, leading: 16, bottom: 0, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 4, trailing: 0)
                return section


            // -----------------------
            // 2️⃣ STATS
            // -----------------------
            case .stats:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(105)
                    )
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(105)
                    ),
                    subitems: [item]
                )

                group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 4, leading: 0, bottom: 4, trailing: 0)
                return section


            // -----------------------
            // 3️⃣ ACTIONS (with header)
            // -----------------------
            case .actions:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(92)
                    )
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(200)
                    ),
                    subitems: [item]
                )

                group.interItemSpacing = .fixed(8)
                group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.contentInsets = .init(top: 4, leading: 0, bottom: 4, trailing: 0)


                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(44)
                )

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                section.boundarySupplementaryItems = [header]

                return section



            // -----------------------
            // 4️⃣ RECENTS (with header)
            // -----------------------
            case .recents:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(140)
                    )
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(140)
                    ),
                    subitems: [item]
                )

                group.interItemSpacing = .fixed(8)
                group.contentInsets = .init(top: 0, leading: 16, bottom: 8, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)


                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(44)
                )

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                section.boundarySupplementaryItems = [header]

                return section

            }
        }

        collectionView.setCollectionViewLayout(layout, animated: false)

        // Register all XIBs
        collectionView.register(
            UINib(nibName: "JournalStreakCell", bundle: nil),
            forCellWithReuseIdentifier: JournalStreakCell.reuseIdentifier
        )
        
        collectionView.register(
            UINib(nibName: "JournalStatsCell", bundle: nil),
            forCellWithReuseIdentifier: JournalStatsCell.reuseIdentifier
        )
        
        collectionView.register(
            UINib(nibName: "JournalActionCell", bundle: nil),
            forCellWithReuseIdentifier: JournalActionCell.reuseIdentifier
        )
        
        collectionView.register(
            UINib(nibName: "RecentJournalCell", bundle: nil),
            forCellWithReuseIdentifier: RecentJournalCell.reuseIdentifier
        )
        
        collectionView.register(
            UINib(nibName: "JournalSectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header_cell"
        )

        
    }
}

