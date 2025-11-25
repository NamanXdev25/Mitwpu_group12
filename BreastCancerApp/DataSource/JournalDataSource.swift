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

    // MARK: - NEW ACTIONS DATA
    struct JournalAction: Hashable {
        let id = UUID()
        let title: String
        let subtitle: String
        let iconName: String
    }

    let actions: [JournalAction] = [
        JournalAction(
            title: "Blank Journal",
            subtitle: "Express yourselves freely with a blank canvas",
            iconName: "pencil.and.scribble"
        ),
        JournalAction(
            title: "Guided Reflection",
            subtitle: "Use thoughtful prompts to guide your journey",
            iconName: "sparkles"
        )
    ]

    // MARK: - Init
    init(collectionView: UICollectionView, entries: [JournalEntry], streak: Int, thisWeekCount: Int) {
        self.collectionView = collectionView
        self.entries = entries
        self.streak = streak
        self.thisWeekCount = thisWeekCount

        configureDataSource()
    }

    // MARK: - Configure DataSource
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) {
            (collectionView, indexPath, id) -> UICollectionViewCell? in

            guard let section = Section(rawValue: indexPath.section) else { return nil }

            switch section {

            // -------------------- STREAK CELL --------------------
            case .streak:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: JournalStreakCell.reuseIdentifier,
                    for: indexPath
                ) as! JournalStreakCell

                cell.configure(streak: self.streak)
                return cell

            // -------------------- STATS CELL ---------------------
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

            // -------------------- ACTION CELL --------------------
            case .actions:
                let action = self.actions[indexPath.item]

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: JournalActionCell.reuseIdentifier,
                    for: indexPath
                ) as! JournalActionCell

                cell.configure(
                    title: action.title,
                    subtitle: action.subtitle,
                    icon: UIImage(systemName: action.iconName) ?? UIImage()
                )
                return cell
            }
        }
    }

    // MARK: - Snapshot
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()

        // 1. Add sections
        snapshot.appendSections([.streak, .stats, .actions])

        // 2. Add items
        snapshot.appendItems([UUID()], toSection: .streak)    // streak cell
        snapshot.appendItems([UUID()], toSection: .stats)     // stats cell

        // Two Action items → Blank Journal + Guided Reflection
        snapshot.appendItems([UUID(), UUID()], toSection: .actions)

        // 3. Apply
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}
