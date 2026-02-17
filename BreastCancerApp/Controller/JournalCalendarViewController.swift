//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 27/11/25.
//

import UIKit

class JournalCalendarViewController: UIViewController {
    
    @IBOutlet weak var journalsCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    // Variables
    var selectedDate = Date()
    private var selectedDay: Date?
    private var filteredJournals: [JournalEntry] = []
    private var journalDays: Set<Date> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupJournalsCollectionView()
        
        journalDays = JournalStore.shared.entries.journalDays
    }
    
    private func setupJournalsCollectionView() {
        // Register cells
        journalsCollectionView.register(
            UINib(nibName: "JournalCalendarCell", bundle: nil),
            forCellWithReuseIdentifier: "JournalCalendarCell"
        )
        
        journalsCollectionView.register(
            UINib(nibName: "RecentJournalCell", bundle: nil),
            forCellWithReuseIdentifier: "RecentJournalCell"
        )
        
        // Set compositional layout
        journalsCollectionView.collectionViewLayout = createLayout()
        journalsCollectionView.dataSource = self
        journalsCollectionView.delegate = self
        journalsCollectionView.backgroundColor = UIColor(named: "BackgroundColor")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            if sectionIndex == 0 {
                // Calendar Section
                return self?.createCalendarSection()
            } else {
                // Journals Section
                return self?.createJournalsSection()
            }
        }
    }
    
    private func createCalendarSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(400)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(400)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createJournalsSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func emptyStateLabel() -> UIView {
        let label = UILabel()
        label.text = "No journal entries"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }
}

extension JournalCalendarViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Section 0: Calendar, Section 1: Journals
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Calendar cell
        }
        return filteredJournals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "JournalCalendarCell",
                for: indexPath
            ) as! JournalCalendarCell
            
            cell.configure(with: selectedDate, journalDays: journalDays, selectedDay: selectedDay)
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecentJournalCell",
            for: indexPath
        ) as! RecentJournalCell
        
        let entry = filteredJournals[indexPath.item]
        cell.configure(with: entry, onEdit: nil, onDelete: nil)
        return cell
    }
}

// calendar VC delegate
extension JournalCalendarViewController: UICollectionViewDelegate {
    
}

// calendar cell delegate
extension JournalCalendarViewController: JournalCalendarCellDelegate {
    func calendarCell(_ cell: JournalCalendarCell, didSelectDate date: Date) {
        selectedDay = date
        filteredJournals = JournalStore.shared.entries.journals(on: date)
        journalsCollectionView.backgroundView = filteredJournals.isEmpty ? emptyStateLabel() : nil
        journalsCollectionView.reloadSections(IndexSet(integer: 1))
    }
    
    func calendarCell(_ cell: JournalCalendarCell, didChangeTo date: Date) {
        selectedDate = date
        filteredJournals.removeAll()
        selectedDay = nil
        journalsCollectionView.backgroundView = nil
        journalsCollectionView.reloadSections(IndexSet(integer: 1))
    }
    
    func calendarCellDidTapHeader(_ cell: JournalCalendarCell) {
        
    }
}
