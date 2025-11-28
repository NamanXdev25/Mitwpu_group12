//
//  JournalDataSource.swift
//  journalTrial
//

import UIKit

class JournalDataSource {

    // MARK: - Sections for BOTH SCREENS
    enum Section: Int, CaseIterable {
        case streak
        case stats
        case actions
        case recents
        case all
    }

    // MARK: - Cell Types
    struct JournalAction: Hashable {
        let id = UUID()
        let title: String
        let subtitle: String
        let iconName: String
    }

    // MARK: - Properties
    private weak var collectionView: UICollectionView?
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!

    var entries: [JournalEntry]
    private var streak: Int
    private var thisWeekCount: Int

    var didTapSeeAll: (() -> Void)?
    
    var didTapBlankJournal: (() -> Void)?
    var didTapGuidedJournal: (() -> Void)?

    
    private var mode: Mode

    // MARK: - Modes
    enum Mode {
        case mainScreen
        case allJournals
    }

    // MARK: - Actions
    let actions: [JournalAction] = [
        JournalAction(title: "New Journal", subtitle: "Express yourself freely with a blank canvas", iconName: "pencil.and.scribble"),
        JournalAction(title: "Guided Reflection", subtitle: "Thoughtful prompts for clarity", iconName: "sparkles")
    ]

    // MARK: - Init
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

    // MARK: - Configure Datasource
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) { collectionView, indexPath, id in

            switch self.mode {

            // MARK: MAIN JOURNAL SCREEN
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

                case .stats:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: JournalStatsCell.reuseIdentifier,
                        for: indexPath
                    ) as! JournalStatsCell
                    cell.configure(total: self.entries.count, thisWeek: self.thisWeekCount)
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
                        if indexPath.item == 0 {  // Blank Journal
                            self?.didTapBlankJournal?()
                        }
                        if indexPath.item == 1 {  // Gided Journal
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
                    cell.configure(with: entry)
                    return cell

                default:
                    return nil
                }

            // MARK: ALL JOURNALS SCREEN
            case .allJournals:

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecentJournalCell.reuseIdentifier,
                    for: indexPath
                ) as! RecentJournalCell

                let entry = self.entries[indexPath.item]
                cell.configure(with: entry)
                return cell
            }
        }

        // MARK: - Headers
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
                case .actions:
                    header.configure(title: "Start Writing", showButton: false)
                case .recents:
                    header.configure(title: "Recent", showButton: true)
                default:
                    header.configure(title: "", showButton: false)
                }

            case .allJournals:
                header.configure(title: "All Journals", showButton: false)
            }
            
            if section == .recents {
                header.configure(title: "Recent", showButton: true)
                header.seeAllTapped = { [weak self] in
                    self?.didTapSeeAll?()
                }

            }

            return header
        }
    }

    // MARK: - Snapshots
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()

        switch mode {

        // MAIN SCREEN SNAPSHOT
        case .mainScreen:
            snapshot.appendSections([.streak, .stats, .actions, .recents])

            snapshot.appendItems([UUID()], toSection: .streak)
            snapshot.appendItems([UUID()], toSection: .stats)
            snapshot.appendItems(actions.map { _ in UUID() }, toSection: .actions)
            //snapshot.appendItems(entries.map { _ in UUID() }, toSection: .recents)
            //snapshot.appendItems(entries.map { $0.id }, toSection: .recents)
            snapshot.appendItems(JournalStore.shared.entries.map { $0.id }, toSection: .recents)



        // ALL JOURNALS SNAPSHOT
        case .allJournals:
            snapshot.appendSections([.all])
            //snapshot.appendItems(entries.map { _ in UUID() }, toSection: .all)
            //snapshot.appendItems(entries.map { $0.id }, toSection: .all)
            snapshot.appendItems(JournalStore.shared.entries.map { $0.id }, toSection: .all)


        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Item Lookup
    /*
    func item(for indexPath: IndexPath) -> JournalEntry? {
        guard indexPath.item < entries.count else { return nil }
        return entries[indexPath.item]
    }
     */
    func item(for indexPath: IndexPath) -> JournalEntry? {
        let id = dataSource.itemIdentifier(for: indexPath)
        return entries.first(where: { $0.id == id })
    }

}
