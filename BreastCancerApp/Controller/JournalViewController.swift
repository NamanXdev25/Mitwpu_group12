import UIKit

class JournalViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addButton: UIButton!

    enum Section: Int, CaseIterable {
        case streak
        case actions
        case recents
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var journalDataSource: JournalDataSource!
    var entries: [JournalEntry] {
        JournalStore.shared.entries
    }

    private var streak: Int {
        JournalStore.shared.entries.streakCount
    }

    private var thisWeekCount: Int {
        JournalStore.shared.entries.journalsThisWeek
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "Journal"
        collectionView.backgroundColor = UIColor(named: "BackgroundColor")

        setupCollectionView()

        journalDataSource = JournalDataSource(
            collectionView: collectionView,
            mode: .mainScreen,
            entries: entries,
            streak: streak,
            thisWeekCount: thisWeekCount
        )

        setupDataSourceCallbacks()
        journalDataSource.applySnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshSnapshot()
    }

    private func setupDataSourceCallbacks() {
        journalDataSource.didTapSeeAll = { [weak self] in
            self?.openAllJournals()
        }

        journalDataSource.didTapBlankJournal = { [weak self] in
            self?.openBlankJournal()
        }

        journalDataSource.didTapGuidedJournal = { [weak self] in
            self?.handleGuidedJournalTap()
        }
        journalDataSource.didTapDelete = { [weak self] entry in
            JournalStore.shared.delete(entry)
            self?.refreshSnapshot()
        }
        journalDataSource.didTapEdit = { [weak self] entry in
            self?.openEntry(entry)
        }
    }

    func refreshSnapshot() {
        journalDataSource.update(
            entries: entries,
            streak: streak,
            thisWeekCount: thisWeekCount
        )
    }

    func handleGuidedJournalTap() {
        if let todayEntry = JournalStore.shared.entries.todayGuidedEntry() {
            openEntry(todayEntry)
        } else {
            openGuidedJournal()
        }
    }

    func openBlankJournal() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "BlankJournalViewController"
        ) as? BlankJournalViewController else {
            fatalError("Expected BlankJournalViewController for identifier 'BlankJournalViewController'")
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    func openGuidedJournal() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "GuidedJournalViewController") as? GuidedJournalViewController else {
            fatalError("Expected GuidedJournalViewController for identifier 'GuidedJournalViewController'")
        }

        vc.categoryText = "MIND • SELF-AWARENESS"
        vc.questionText = "What thought has been taking up too much space in your mind lately?"

        navigationController?.pushViewController(vc, animated: true)
    }

    func openAllJournals() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "AllJournalsViewController"
        ) as? AllJournalsViewController else {
            fatalError("Expected AllJournalsViewController for identifier 'AllJournalsViewController'")
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func openEntry(_ entry: JournalEntry) {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        switch entry.type {
        case .regular:
            guard let vc = storyboard.instantiateViewController(
                withIdentifier: "BlankJournalViewController"
            ) as? BlankJournalViewController else {
                fatalError("Expected BlankJournalViewController for identifier 'BlankJournalViewController'")
            }
            vc.existingEntry = entry
            navigationController?.pushViewController(vc, animated: true)
        case .guided:
            guard let vc = storyboard.instantiateViewController(
                withIdentifier: "GuidedJournalViewController"
            ) as? GuidedJournalViewController else {
                fatalError("Expected GuidedJournalViewController for identifier 'GuidedJournalViewController'")
            }
            vc.existingEntry = entry
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func calendarTapped(_: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        let nav = storyboard.instantiateViewController(
            withIdentifier: "CalendarNavController"
        )
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @IBAction func addJournalTapped() {
        openBlankJournal()
    }
}

extension JournalViewController {
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let self = self, let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .streak: return self.createStreakSection()
            case .actions: return self.createActionsSection()
            case .recents: return self.createRecentsSection()
            }
        }

        collectionView.setCollectionViewLayout(layout, animated: false)
        registerCells()
    }

    private func createStreakSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(104)), subitems: [item]
        )
        group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }

    private func createActionsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(92)))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item]
        )
        group.interItemSpacing = .fixed(8)
        group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 4, leading: 0, bottom: 16, trailing: 0)
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }

    private func createRecentsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(140)))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(140)), subitems: [item]
        )
        group.interItemSpacing = .fixed(8)
        group.contentInsets = .init(top: 0, leading: 16, bottom: 8, trailing: 16)
        let section = NSCollectionLayoutSection(group: group)
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }

    private func registerCells() {
        collectionView.register(UINib(nibName: "JournalStreakCell", bundle: nil), forCellWithReuseIdentifier: JournalStreakCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "JournalStatsCell", bundle: nil), forCellWithReuseIdentifier: JournalStatsCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "JournalActionCell", bundle: nil), forCellWithReuseIdentifier: JournalActionCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "RecentJournalCell", bundle: nil), forCellWithReuseIdentifier: RecentJournalCell.reuseIdentifier)
        collectionView.register(
            UINib(nibName: "JournalSectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell"
        )
    }
}

extension JournalViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let entry = journalDataSource.item(for: indexPath),
           indexPath.section == Section.recents.rawValue {
            openEntry(entry)
        }
    }
}
