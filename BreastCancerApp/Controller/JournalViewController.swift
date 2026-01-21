//
//  JournalViewController.swift
//  journalTrial
//
//  Created by Shivani Dinesh on 24/11/25.
//

import UIKit

class JournalViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!

    enum Section: Int, CaseIterable {
        case streak
        case actions
        case recents
    }
    
    private var journalDataSource: JournalDataSource!
    var entries: [JournalEntry] {
        JournalStore.shared.entries
    }
    //for streak & stats
    private var streak: Int {
        JournalStore.shared.entries.streakCount
    }

    private var thisWeekCount: Int {
        JournalStore.shared.entries.journalsThisWeek
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI (color/screen-title)
        view.backgroundColor = UIColor(named: "BackgroundColor")
        navigationItem.title = "Journal"
        collectionView.backgroundColor = UIColor(named: "BackgroundColor")
        
        // build layout & register cells (XIBs)
        setupCollectionView()

        // initialising data source
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
    
    // viewWillAppear
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
            openEntry(todayEntry)   // if already wrote today's guided journal
        } else {
            openGuidedJournal()     // if first time today
        }
    }
    
    func openBlankJournal() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "BlankJournalViewController"
        ) as! BlankJournalViewController
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openGuidedJournal() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GuidedJournalViewController") as! GuidedJournalViewController
        
        vc.categoryText = "MIND • SELF-AWARENESS"
        vc.questionText = "What thought has been taking up too much space in your mind lately?"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openAllJournals() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "AllJournalsViewController"
        ) as! AllJournalsViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    func openEntry(_ entry: JournalEntry) {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        switch entry.type {
        case .regular:
            let vc = storyboard.instantiateViewController(
                withIdentifier: "BlankJournalViewController"
            ) as! BlankJournalViewController
            vc.existingEntry = entry
            navigationController?.pushViewController(vc, animated: true)
        case .guided:
            let vc = storyboard.instantiateViewController(
                withIdentifier: "GuidedJournalViewController"
            ) as! GuidedJournalViewController
            vc.existingEntry = entry
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func calendarTapped(_ sender: UIBarButtonItem) {
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

        // Compositional Layout for all sections
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
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
                        heightDimension: .absolute(104)
                    ),
                    subitems: [item]
                )

                group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
                
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
                section.contentInsets = .init(top: 4, leading: 0, bottom: 16, trailing: 0)


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

        // register all XIBs
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

extension JournalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let entry = journalDataSource.item(for: indexPath),
           indexPath.section == Section.recents.rawValue {
            openEntry(entry)
        }
    }
}
