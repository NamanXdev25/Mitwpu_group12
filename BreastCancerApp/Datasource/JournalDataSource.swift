//
//  JournalDataSource.swift
//  journalTrial
//

import UIKit

class JournalDataSource {

    // Sections
    enum Section: Int, CaseIterable {
        case streak
        case actions
        case recents
        case all
    }

    // Action Cell
    struct JournalAction: Hashable {
        let id = UUID()
        let title: String
        let subtitle: String
        let iconName: String
    }

    // Variables
    private weak var collectionView: UICollectionView?
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!

    var entries: [JournalEntry]
    private var streak: Int
    private var thisWeekCount: Int

    // buttons
    var didTapSeeAll: (() -> Void)?
    
    var didTapBlankJournal: (() -> Void)?
    var didTapGuidedJournal: (() -> Void)?
    
    var didTapDelete: ((JournalEntry)->Void)?
    var didTapEdit: ((JournalEntry)->Void)?


    // Modes
    private var mode: Mode
    
    enum Mode {
        case mainScreen
        case allJournals
    }

    // Actions
    let actions: [JournalAction] = [
        JournalAction(title: "Guided Reflection", subtitle: "Prompts for everyday journaling", iconName: "sparkles")
    ]

    // Init
    init(
        collectionView: UICollectionView,
        mode: Mode,
        entries: [JournalEntry],
        streak: Int = 0,
        thisWeekCount: Int = 0
    ) {
        self.collectionView = collectionView
        self.entries = entries
        self.streak = streak
        self.thisWeekCount = thisWeekCount
        self.mode = mode

        configureDataSource()
    }
    
    // Configure datasource
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) { collectionView, indexPath, id in

            switch self.mode {
            // Main screen
            case .mainScreen:
                guard let section = Section(rawValue: indexPath.section) else { return nil }
                switch section {
                    case .streak:
                        let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: JournalStreakCell.reuseIdentifier,
                            for: indexPath
                        ) as! JournalStreakCell
                        cell.configure(streak: self.streak)
                        return cell

                    case .actions:
                        let actionItem = self.actions[indexPath.item]
                        let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: JournalActionCell.reuseIdentifier,
                            for: indexPath
                        ) as! JournalActionCell
                        
                        cell.configure(
                            title: actionItem.title,
                            subtitle: actionItem.subtitle,
                            icon: UIImage(systemName: actionItem.iconName) ?? UIImage()
                        )
                        cell.didTap = {
                            [weak self] in
                            if indexPath.item == 0 {  // Guided Journal
                                self?.didTapGuidedJournal?()
                            }
                        }
                        return cell

                    case .recents:
                        let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: RecentJournalCell.reuseIdentifier,
                            for: indexPath
                        ) as! RecentJournalCell

                        let entry = self.entries[indexPath.item]

                        cell.configure(
                            with: entry,
                            onEdit: { [weak self] entry in
                                self?.didTapEdit?(entry)
                            },
                            onDelete: { [weak self] entry in
                                self?.didTapDelete?(entry)
                            }
                        )
                        return cell
                    
                    default:
                        return nil
                }

            // All journals screen
            case .allJournals:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecentJournalCell.reuseIdentifier,
                    for: indexPath
                ) as! RecentJournalCell

                let entry = self.entries[indexPath.item]
                cell.configure(
                    with: entry,
                    onEdit: { [weak self] entry in
                        self?.didTapEdit?(entry)
                    },
                    onDelete: { [weak self] entry in
                        self?.didTapDelete?(entry)
                    }
                )

                return cell
            }
        }

        // Headers
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let section = Section(rawValue: indexPath.section) else { return nil }

            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header_cell",
                for: indexPath
            ) as! JournalSectionHeaderView

            switch self.mode {

            case .mainScreen:
                switch section {
                case .streak:
                    header.configure(title: "Streaks", showButton: false)
                case .actions:
                    header.configure(title: "Tools", showButton: false)
                case .recents:
                    header.configure(title: "Recents", showButton: true)
                    header.seeAllTapped = { [weak self] in
                        self?.didTapSeeAll?()
                    }
                default:
                    header.configure(title: "", showButton: false)
                }

            case .allJournals:
                header.configure(title: "All Journals", showButton: false)
            }

            return header
        }
    }

    // SNAPSHOTS
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()

        switch mode {
            
        // MAIN SCREEN SNAPSHOT
        case .mainScreen:
            snapshot.appendSections([.streak, .actions, .recents])
            
            snapshot.appendItems([UUID()], toSection: .streak)
            snapshot.appendItems(actions.map { $0.id }, toSection: .actions)
            let recent3 = Array(entries.prefix(3))
            snapshot.appendItems(recent3.map { $0.id }, toSection: .recents)
            snapshot.reconfigureItems(recent3.map { $0.id })

        // ALL JOURNALS SNAPSHOT
        case .allJournals:
            snapshot.appendSections([.all])
            snapshot.appendItems(entries.map { $0.id }, toSection: .all)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // ITEM LOOKUP
    func item(for indexPath: IndexPath) -> JournalEntry? {
        let id = dataSource.itemIdentifier(for: indexPath)
        return entries.first(where: { $0.id == id })
    }
    
    func update(entries: [JournalEntry], streak: Int, thisWeekCount: Int) {
        self.entries = entries
        self.streak = streak
        self.thisWeekCount = thisWeekCount
        applySnapshot()
    }
    
}
