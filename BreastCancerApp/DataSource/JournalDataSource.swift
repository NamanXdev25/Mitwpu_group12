import UIKit

class JournalDataSource {
    enum Section: Int, CaseIterable {
        case streak
        case actions
        case recents
        case all
    }

    struct JournalAction: Hashable {
        let id = UUID()
        let title: String
        let subtitle: String
        let iconName: String
    }

    private weak var collectionView: UICollectionView?
    // swiftlint:disable:next implicitly_unwrapped_optional
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!

    var entries: [JournalEntry]
    private var streak: Int
    private var thisWeekCount: Int

    var didTapSeeAll: (() -> Void)?

    var didTapBlankJournal: (() -> Void)?
    var didTapGuidedJournal: (() -> Void)?

    var didTapDelete: ((JournalEntry) -> Void)?
    var didTapEdit: ((JournalEntry) -> Void)?

    private var mode: Mode

    enum Mode {
        case mainScreen
        case allJournals
    }

    let actions: [JournalAction] = [
        JournalAction(title: "Guided Reflection", subtitle: "Prompts for everyday journaling", iconName: "sparkles"),
    ]

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

    private func configureDataSource() {
        guard let collectionView = collectionView else { return }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) { collectionView, indexPath, _ in
            switch self.mode {
            case .mainScreen:
                guard let section = Section(rawValue: indexPath.section) else { return nil }
                return self.configureMainScreenCell(collectionView: collectionView, indexPath: indexPath, section: section)
            case .allJournals:
                return self.configureAllJournalsCell(collectionView: collectionView, indexPath: indexPath)
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            return self.configureHeader(collectionView: collectionView, kind: kind, indexPath: indexPath, section: section)
        }
    }

    private func configureMainScreenCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        section: Section
    ) -> UICollectionViewCell? {
        switch section {
        case .streak:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: JournalStreakCell.reuseIdentifier,
                for: indexPath
            ) as? JournalStreakCell else {
                fatalError("Expected JournalStreakCell for reuse identifier '\(JournalStreakCell.reuseIdentifier)' at \(indexPath)")
            }
            cell.configure(streak: self.streak)
            return cell

        case .actions:
            let actionItem = self.actions[indexPath.item]
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: JournalActionCell.reuseIdentifier,
                for: indexPath
            ) as? JournalActionCell else {
                fatalError("Expected JournalActionCell for reuse identifier '\(JournalActionCell.reuseIdentifier)' at \(indexPath)")
            }
            cell.configure(
                title: actionItem.title,
                subtitle: actionItem.subtitle,
                icon: UIImage(systemName: actionItem.iconName) ?? UIImage()
            )
            cell.didTap = { [weak self] in
                if indexPath.item == 0 { self?.didTapGuidedJournal?() }
            }
            return cell

        case .recents:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecentJournalCell.reuseIdentifier,
                for: indexPath
            ) as? RecentJournalCell else {
                fatalError("Expected RecentJournalCell for reuse identifier '\(RecentJournalCell.reuseIdentifier)' at \(indexPath)")
            }
            cell.configure(
                with: self.entries[indexPath.item],
                onEdit: { [weak self] entry in self?.didTapEdit?(entry) },
                onDelete: { [weak self] entry in self?.didTapDelete?(entry) }
            )
            return cell

        default:
            return nil
        }
    }

    private func configureAllJournalsCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecentJournalCell.reuseIdentifier,
            for: indexPath
        ) as? RecentJournalCell else {
            fatalError("Expected RecentJournalCell for reuse identifier '\(RecentJournalCell.reuseIdentifier)' at \(indexPath)")
        }
        cell.configure(
            with: self.entries[indexPath.item],
            onEdit: { [weak self] entry in self?.didTapEdit?(entry) },
            onDelete: { [weak self] entry in self?.didTapDelete?(entry) }
        )
        return cell
    }

    private func configureHeader(
        collectionView: UICollectionView,
        kind: String,
        indexPath: IndexPath,
        section: Section
    ) -> UICollectionReusableView? {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header_cell",
            for: indexPath
        ) as? JournalSectionHeaderView else {
            fatalError("Expected JournalSectionHeaderView for reuse identifier 'header_cell' at \(indexPath)")
        }

        switch self.mode {
        case .mainScreen:
            switch section {
            case .streak: header.configure(title: "Streaks", showButton: false)
            case .actions: header.configure(title: "Tools", showButton: false)
            case .recents:
                header.configure(title: "Recents", showButton: true)
                header.seeAllTapped = { [weak self] in self?.didTapSeeAll?() }
            default: header.configure(title: "", showButton: false)
            }
        case .allJournals:
            header.configure(title: "All Journals", showButton: false)
        }
        return header
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()

        switch mode {
        case .mainScreen:
            let hasEntries = !entries.isEmpty
            var sections: [Section] = [.streak, .actions]
            if hasEntries { sections.append(.recents) }
            snapshot.appendSections(sections)

            snapshot.appendItems([UUID()], toSection: .streak)
            snapshot.appendItems(actions.map { $0.id }, toSection: .actions)

            if hasEntries {
                let recent3 = Array(entries.prefix(3))
                snapshot.appendItems(recent3.map { $0.id }, toSection: .recents)
                snapshot.reconfigureItems(recent3.map { $0.id })
            }

        case .allJournals:
            snapshot.appendSections([.all])
            snapshot.appendItems(entries.map { $0.id }, toSection: .all)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

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
