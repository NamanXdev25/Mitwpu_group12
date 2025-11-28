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
    //private var entries: [JournalEntry] = SampleJournalData.all
    var entries: [JournalEntry] {
        JournalStore.shared.entries
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "All Journals"
        
        configureCollectionView()
        configureDataSource()
    }
    
    private func configureCollectionView() {
        // 1) Layout: one item per vertical group, then set interGroupSpacing
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // optional: add content insets inside the item so cell content has horizontal padding
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [ item ]
        )

        // add horizontal insets for the group (left/right padding)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)

        // <-- THIS is the vertical spacing between each "card"
        section.interGroupSpacing = 0   // change to 8 / 12 / 16 as you like

        // optional: section top/bottom padding
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)

        // Build layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout

        // 2) delegate & registration (same as before)
        collectionView.delegate = self
        collectionView.register(
            UINib(nibName: "RecentJournalCell", bundle: nil),
            forCellWithReuseIdentifier: RecentJournalCell.reuseIdentifier
        )

        // register header if you need
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

//        dataSource.entries = JournalStore.shared.entries
//        dataSource.applySnapshot()
        
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
            entries: entries   // Pass same entries
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
