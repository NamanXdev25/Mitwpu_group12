//
//  AllJournalsViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 26/11/25.
//

import UIKit

class AllJournalsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case all
    }
    
    private var dataSource: JournalDataSource!
    private var layout: UICollectionViewLayout!
    var entries: [JournalEntry] {
        JournalStore.shared.entries
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "All Journals"
        
        configureCollectionView()
        configureDataSource()
    }
    
    private func configureCollectionView() {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [ item ]
        )

        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 0

        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout

        collectionView.delegate = self
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
    
    private func refreshList() {
        dataSource.entries = JournalStore.shared.entries
        dataSource.applySnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource = JournalDataSource(
                collectionView: collectionView,
                mode: .allJournals,
                entries: JournalStore.shared.entries
            )
        
        dataSource.didTapEdit = { [weak self] entry in
                self?.openEntry(entry)
            }

        dataSource.didTapDelete = { [weak self] entry in
            JournalStore.shared.delete(entry)
            self?.refreshList()
        }

        dataSource.applySnapshot()

    }


    
    private func configureDataSource() {
        
        dataSource = JournalDataSource(
            collectionView: collectionView,
            mode: .allJournals,
            entries: entries
        )
        
        dataSource.didTapEdit = { [weak self] entry in
            self?.openEntry(entry)
        }

        dataSource.didTapDelete = { [weak self] entry in
            JournalStore.shared.delete(entry)
            self?.refreshList()
        }
        dataSource.applySnapshot()
        
    }

}

extension AllJournalsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let entry = dataSource.item(for: indexPath) else { return }
        openEntry(entry)
    }
    
    private func openEntry(_ entry: JournalEntry) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

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


}
