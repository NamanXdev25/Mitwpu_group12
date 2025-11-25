//
//  JournalDataSource.swift
//  journalTrial
//

import UIKit

class JournalDataSource {

    typealias Section = JournalViewController.Section

    private weak var collectionView: UICollectionView?
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!

    private var entries: [JournalEntry]
    private var streak: Int
    private var thisWeekCount: Int

    // MARK: - ACTIONS DATA MODEL
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
                
                cell.configure(total: self.entries.count, thisWeek: self.thisWeekCount)
                return cell

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

            case .recents:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecentJournalCell.reuseIdentifier,
                    for: indexPath
                ) as! RecentJournalCell
                
                let entry = self.entries[indexPath.item]
                cell.configure(with: entry)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let section = Section(rawValue: indexPath.section) else { return nil }

            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header_cell",
                for: indexPath
            ) as! JournalSectionHeaderView

            switch section {
            case .actions:
                header.configure(title: "Start Writing", showButton: false)

            case .recents:
                header.configure(title: "Recent", showButton: true)

            default:
                header.configure(title: "", showButton: false)
            }

            return header
        }

    }

    func applySnapshot() { var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        // 1. Add sections
        snapshot.appendSections([.streak, .stats, .actions, .recents])
        // 2. Add items
        snapshot.appendItems([UUID()], toSection: .streak)
        // streak cell
        snapshot.appendItems([UUID()], toSection: .stats)
        // stats cell
        // Two Action items → Blank Journal + Guided Reflection
        snapshot.appendItems([UUID(), UUID()], toSection: .actions)
        // recents cell
        snapshot.appendItems(entries.map { _ in UUID() }, toSection: .recents)
        // 3. Apply
        dataSource.apply(snapshot, animatingDifferences: false) }
}
