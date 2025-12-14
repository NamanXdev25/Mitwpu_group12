//
//  AllJournalsViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 26/11/25.
//

import UIKit

class AllJournalsViewController: UIViewController {

    // IBOUtlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // sections
    enum Section: Int, CaseIterable {
        case all
    }
    
    // variables
    private var dataSource: JournalDataSource!
    private var layout: UICollectionViewLayout!
    var entries: [JournalEntry] {
        JournalStore.shared.entries
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        navigationItem.title = "All Journals"
        
        // function calls
        configureCollectionView()
        configureDataSource()
    }
    
    // setup collection view (using compositional layout)
    private func configureCollectionView() {
        
        // item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        // group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [ item ]
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        // section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)

        // layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
        
        // delegate
        collectionView.delegate = self
        
        // registrer XIBs (nib files)
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
    
    // viewWillAppear (after editing a journal)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // setup datasource
        configureDataSource()
    }
    
    // refresh when it reappears (after edit/delete/etc.)
    private func refreshList() {
        dataSource.entries = JournalStore.shared.entries
        dataSource.applySnapshot()
    }
  
    // config datasource
    private func configureDataSource() {
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
}

// delegate extension
extension AllJournalsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let entry = dataSource.item(for: indexPath) else { return }
        openEntry(entry)
    }
    
    // set storyboard
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
