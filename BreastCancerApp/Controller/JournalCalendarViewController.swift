//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 27/11/25.
//

import UIKit

class JournalCalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var journalsCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var previousMonth: UIButton!
    @IBOutlet weak var nextMonth: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    @IBOutlet weak var headerToggleButton: UIButton! // invisible button over "Month Year"
    @IBOutlet weak var chevronButton: UIButton!
    
    // variables
    var selectedDate = Date()
    private var selectedDay: Date?
    var totalSquares = [String]()
    private var filteredJournals: [JournalEntry] = []
    private var journalDays: Set<Date> = []
    
    // calendar data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup calendar collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // setup calendar collection view layout
        let journalLayout = UICollectionViewFlowLayout()
        journalLayout.minimumLineSpacing = 8
        journalLayout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        journalsCollectionView.collectionViewLayout = journalLayout
        journalsCollectionView.dataSource = self
        journalsCollectionView.delegate = self
        
        // register cell XIBs / nib files
        collectionView.register(UINib(nibName: "JournalCalendarDateCell", bundle: nil), forCellWithReuseIdentifier: "JournalCalendarDateCell")
        journalsCollectionView.register(
            UINib(nibName: "RecentJournalCell", bundle: nil),
            forCellWithReuseIdentifier: "RecentJournalCell"
        )
        
        // picker setup
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true // Hidden by default
        
        // Populate Years (e.g., 2020 - 2040)
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...(currentYear + 10))

        journalDays = JournalStore.shared.entries.journalDays
        
        // function calls
        setMonthView()
        configureJournalsCollectionView()
    }
    
    // collection view
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
                withReuseIdentifier: "JournalCalendarDateCell",
                for: indexPath
            ) as! JournalCalendarDateCell

            let dayString = totalSquares[indexPath.item]

            var hasJournal = false
            var isSelected = false
            var isToday = false
            var isFuture = false

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

                    isToday = calendar.isDateInToday(normalized)
                    isFuture = normalized > calendar.startOfDay(for: Date())
                }
            }

            cell.configure(
                day: dayString,
                hasJournal: hasJournal,
                isSelected: isSelected,
                isToday: isToday,
                isFuture: isFuture
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

    // when no journals
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
        // only sizing calendar grid cells
        if collectionView == self.collectionView {
            let width = collectionView.frame.width / 7
            return CGSize(width: width, height: 40)
        }
        // compositional layout handles journal cells
        return CGSize(width: 0, height: 0)
    }
    
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = ExerciseCalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = ExerciseCalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = ExerciseCalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        while(count < startingSpaces) {
            totalSquares.append("")
            count += 1
        }
        for i in 1...daysInMonth {
            totalSquares.append(String(i))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: selectedDate)
        
        collectionView.reloadData()
    
        // sync picker to current selection
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
    
    // IBActions
    
    @IBAction func headerToggleButton(_ sender: Any) {
        let isPickerVisible = !pickerContainerView.isHidden
        
        if isPickerVisible {
            // hide picker & show calendar
            pickerContainerView.isHidden = true
            collectionView.isHidden = false
            monthLabel.textColor = .label
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = .identity    // point right
            }
        } else {
            // show picker & hide calendar
            pickerContainerView.isHidden = false
            collectionView.isHidden = true
            monthLabel.textColor = UIColor(named : "PrimaryColor")
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: .pi / 2) // Point Down
            }
            
            syncPickerToDate()
        }
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = ExerciseCalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = ExerciseCalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // picker view delegate
    
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
        // get new month and year from the picker
        let monthIndex = pickerView.selectedRow(inComponent: 0) + 1 // Months are 1-12
        let yearIndex = pickerView.selectedRow(inComponent: 1)
        let year = years[yearIndex]
        
        // create a new Date object from these components
        var components = DateComponents()
        components.year = year
        components.month = monthIndex
        components.day = 1 // Always start at the 1st of the month
        
        if let newDate = Calendar.current.date(from: components) {
            // update the main variable
            selectedDate = newDate
            
            // refresh grid immediately (recalculates days & reloads collection view)
            setMonthView()
            
            // update header label immediately
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

        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: date)
        if selected > today {
            return
        }

        selectedDay = selected
        filteredJournals = JournalStore.shared.entries.journals(on: selected)
        journalsCollectionView.backgroundView = filteredJournals.isEmpty ? emptyStateLabel() : nil

        journalsCollectionView.reloadData()
        collectionView.reloadData()
    }


    // collection view using compositional layout
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
            forCellWithReuseIdentifier: "RecentJournalCell"
        )
    }
}

// helper class
class ExerciseCalendarHelper {
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
