//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 27/11/25.
//

import UIKit

class JournalCalendarViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var journalsCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    // Variables
    var selectedDate = Date()
    private var selectedDay: Date?
    private var filteredJournals: [JournalEntry] = []
    private var journalDays: Set<Date> = []
    private var isPickerVisible = false
    
    // Calendar data for picker
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupJournalsCollectionView()
        setupPicker()
        
        journalDays = JournalStore.shared.entries.journalDays
        
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...(currentYear + 10))
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
    
    private func setupPicker() {
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true
        pickerContainerView.layer.cornerRadius = 20
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return months.count }
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return months[row] }
        return String(years[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let monthIndex = pickerView.selectedRow(inComponent: 0) + 1
        let yearIndex = pickerView.selectedRow(inComponent: 1)
        let year = years[yearIndex]
        
        var components = DateComponents()
        components.year = year
        components.month = monthIndex
        components.day = 1
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
            journalsCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private func syncPickerToDate() {
        let calendar = Calendar.current
        let monthIndex = calendar.component(.month, from: selectedDate) - 1
        let year = calendar.component(.year, from: selectedDate)
        
        if let yearIndex = years.firstIndex(of: year) {
            monthYearPicker.selectRow(monthIndex, inComponent: 0, animated: false)
            monthYearPicker.selectRow(yearIndex, inComponent: 1, animated: false)
        }
    }
    
    private func togglePicker() {
        isPickerVisible.toggle()
        
        UIView.animate(withDuration: 0.3) {
            self.pickerContainerView.isHidden = !self.isPickerVisible
        }
        
        if isPickerVisible {
            syncPickerToDate()
        }
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
        journalsCollectionView.reloadSections(IndexSet(integer: 1))
    }
    
    func calendarCellDidTapHeader(_ cell: JournalCalendarCell) {
        togglePicker()
        
        // chevron rotation
        if let indexPath = journalsCollectionView.indexPath(for: cell),
           let calendarCell = journalsCollectionView.cellForItem(at: indexPath) as? JournalCalendarCell {
            UIView.animate(withDuration: 0.3) {
                if self.isPickerVisible {
                    calendarCell.chevronButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
                } else {
                    calendarCell.chevronButton.transform = .identity
                }
            }
        }
    }
}
