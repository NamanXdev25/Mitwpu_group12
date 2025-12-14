//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 27/11/25.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {
    // --- OUTLETS ---
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var journalsCollectionView: UICollectionView!

    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    // Outlets for navigation arrows
    @IBOutlet weak var previousMonth: UIButton!
    @IBOutlet weak var nextMonth: UIButton!
    
    // NEW: Picker Outlets
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    // NEW: Header Interaction Outlets
    @IBOutlet weak var headerToggleButton: UIButton! // The invisible button over "Apr 2025"
    @IBOutlet weak var chevronButton: UIButton!      // The pink chevron >
    
    
    
    // --- VARIABLES ---
    var selectedDate = Date()
    private var selectedDay: Date?
    var totalSquares = [String]()
    private var filteredJournals: [JournalEntry] = []

    
    private var journalDays: Set<Date> = []
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Journal Calendar"

        journalsCollectionView.backgroundColor = .clear
        journalsCollectionView.backgroundView = nil

        // 1. Setup Collection View
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 2. Register Cell
        collectionView.register(UINib(nibName: "CalendarDateCell", bundle: nil), forCellWithReuseIdentifier: "CalendarDateCell")
        
        // 3. Picker Setup
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true // Hidden by default
       // pickerContainerView.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.96, alpha: 1.0) // Light Pink Background
        
        // Populate Years (e.g., 2020 - 2040)
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...(currentYear + 10))
        
        // 4. Initial Setup
        journalDays = JournalStore.shared.entries.journalDays
        setMonthView()
        
        // Journals list layout
        let journalLayout = UICollectionViewFlowLayout()
        journalLayout.minimumLineSpacing = 8
        journalLayout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        journalsCollectionView.collectionViewLayout = journalLayout
        journalsCollectionView.dataSource = self
        journalsCollectionView.delegate = self

        journalsCollectionView.register(
            UINib(nibName: "RecentJournalCell", bundle: nil),
            forCellWithReuseIdentifier: RecentJournalCell.reuseIdentifier
        )
        
        configureJournalsCollectionView()


    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return totalSquares.count
        } else {
            return filteredJournals.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // CALENDAR GRID
        if collectionView == self.collectionView {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CalendarDateCell",
                for: indexPath
            ) as! CalendarDateCell

            let dayString = totalSquares[indexPath.item]

            var hasJournal = false
            var isSelected = false

            if let day = Int(dayString) {
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month], from: selectedDate)
                components.day = day

                if let date = calendar.date(from: components) {
                    let normalized = calendar.startOfDay(for: date)

                    hasJournal = journalDays.contains(normalized)
                    isSelected = selectedDay.map {
                        calendar.isDate($0, inSameDayAs: normalized)
                    } ?? false
                }
            }

            cell.configure(
                day: dayString,
                hasJournal: hasJournal,
                isSelected: isSelected
            )

            return cell
        }


        // JOURNAL LIST
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecentJournalCell.reuseIdentifier,
            for: indexPath
        ) as! RecentJournalCell

        let entry = filteredJournals[indexPath.item]
        cell.configure(with: entry, onEdit: nil, onDelete: nil)
        return cell
    }

    private func emptyStateLabel() -> UIView {
        let label = UILabel()
        label.text = "No journal entries"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        // ONLY size calendar grid cells
        if collectionView == self.collectionView {
            let width = collectionView.frame.width / 7
            return CGSize(width: width, height: 40)
        }

        // Let compositional layout handle journal cells
        return CGSize(width: 0, height: 0)
    }





    
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        while(count < startingSpaces) {
            totalSquares.append("")
            count += 1
        }
        for i in 1...daysInMonth {
            totalSquares.append(String(i))
        }
        
        // Update Title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: selectedDate)
        
        collectionView.reloadData()
        
        // Sync Picker to current selection
        syncPickerToDate()
        
        filteredJournals.removeAll()
        journalsCollectionView.reloadData()
        journalsCollectionView.backgroundView = emptyStateLabel()

    }
    
    func syncPickerToDate() {
        let calendar = Calendar.current
        let monthIndex = calendar.component(.month, from: selectedDate) - 1 // 0-11
        let year = calendar.component(.year, from: selectedDate)
        
        if let yearIndex = years.firstIndex(of: year) {
            monthYearPicker.selectRow(monthIndex, inComponent: 0, animated: false)
            monthYearPicker.selectRow(yearIndex, inComponent: 1, animated: false)
        }
    }
    
    // --- ACTIONS ---
    
    @IBAction func headerToggleButton(_ sender: Any) {
        let isPickerVisible = !pickerContainerView.isHidden
        
        if isPickerVisible {
            // HIDE Picker -> Show Calendar
            pickerContainerView.isHidden = true
            collectionView.isHidden = false
            
            // Restore Styles
            monthLabel.textColor = .black
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = .identity // Point Right
            }
        } else {
            // SHOW Picker -> Hide Calendar
            pickerContainerView.isHidden = false
            collectionView.isHidden = true
            
            // Active Styles
            monthLabel.textColor = UIColor(named : "PrimaryColor") // Dark Pink
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: .pi / 2) // Point Down
            }
            
            // Ensure picker shows correct date before appearing
            syncPickerToDate()
        }
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // --- PICKER VIEW DELEGATE ---
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // Month, Year
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
        // 1. Get the new month and year from the picker
        let monthIndex = pickerView.selectedRow(inComponent: 0) + 1 // Months are 1-12
        let yearIndex = pickerView.selectedRow(inComponent: 1)
        let year = years[yearIndex]
        
        // 2. Create a new Date object from these components
        var components = DateComponents()
        components.year = year
        components.month = monthIndex
        components.day = 1 // Always start at the 1st of the month
        
        if let newDate = Calendar.current.date(from: components) {
            // 3. Update the main variable
            selectedDate = newDate
            
            // 4. REFRESH THE GRID IMMEDIATELY!
            // This recalculates the days and reloads the collection view
            setMonthView()
            
            // 5. Update the Header Label immediately too
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            monthLabel.text = dateFormatter.string(from: selectedDate)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == self.collectionView else { return }

        let dayString = totalSquares[indexPath.item]
        guard let day = Int(dayString) else { return }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: selectedDate)
        components.day = day

        guard let date = calendar.date(from: components) else { return }

        selectedDay = date

        filteredJournals = JournalStore.shared.entries.journals(on: date)
        journalsCollectionView.backgroundView =
            filteredJournals.isEmpty ? emptyStateLabel() : nil

        journalsCollectionView.reloadData()
        collectionView.reloadData() // 🔴 IMPORTANT: refresh calendar selection
    }

    
    private func configureJournalsCollectionView() {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 0,
            bottom: 24,
            trailing: 0
        )

        let layout = UICollectionViewCompositionalLayout(section: section)
        journalsCollectionView.collectionViewLayout = layout

        journalsCollectionView.backgroundColor = .clear
        journalsCollectionView.delegate = self
        journalsCollectionView.dataSource = self

        journalsCollectionView.register(
            UINib(nibName: "RecentJournalCell", bundle: nil),
            forCellWithReuseIdentifier: RecentJournalCell.reuseIdentifier
        )
    }

    
    

}

// --- HELPER CLASS ---
class CalendarHelper {
    let calendar = Calendar.current
    
    func plusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func daysInMonth(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func weekDay(date: Date) -> Int {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday!
    }
}
