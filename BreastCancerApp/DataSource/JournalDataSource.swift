//
//  JournalDataSource.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import UIKit

class JournalDataSource {

    typealias Section = JournalViewController.Section

    private weak var collectionView: UICollectionView?
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!

    private var entries: [JournalEntry]
    private var streak: Int
    private var thisWeekCount: Int

    init(collectionView: UICollectionView, entries: [JournalEntry], streak: Int, thisWeekCount: Int) {
        self.collectionView = collectionView
        self.entries = entries
        self.streak = streak
        self.thisWeekCount = thisWeekCount

        configureDataSource()
    }

    private func configureDataSource() {
        guard let collectionView = collectionView else { return }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) {
            (collectionView, indexPath, id) -> UICollectionViewCell? in

            guard let section = Section(rawValue: indexPath.section) else { return nil }

            switch section {

            case .streak:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: JournalStreakCell.reuseIdentifier,
                    for: indexPath
                ) as! JournalStreakCell

                cell.configure(streak: self.streak)
                return cell

            case .stats:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: JournalStatsCell.reuseIdentifier,
                    for: indexPath
                ) as! JournalStatsCell

                cell.configure(
                    total: self.entries.count,
                    thisWeek: self.thisWeekCount
                )
                return cell
            }
        }

    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.streak, .stats])
        
        snapshot.appendItems([UUID()], toSection: .stats)
        snapshot.appendItems([UUID()], toSection: .streak)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
