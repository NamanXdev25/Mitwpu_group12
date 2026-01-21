//
//  JournalCalendarCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 19/01/26.
//

import UIKit

protocol JournalCalendarCellDelegate: AnyObject {
    func calendarCell(_ cell: JournalCalendarCell, didSelectDate date: Date)
    func calendarCell(_ cell: JournalCalendarCell, didChangeTo date: Date)
    func calendarCellDidTapHeader(_ cell: JournalCalendarCell)
}

class JournalCalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var headerToggleButton: UIButton!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    weak var delegate: JournalCalendarCellDelegate?
    
    var selectedDate = Date()
    private var selectedDay: Date?
    var totalSquares = [String]()
    var journalDays: Set<Date> = []
    
    // Picker data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupYears()
        setupCollectionView()
        setupPicker()
    }
    
    private func setupYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...(currentYear + 10))
    }
    
    private func setupPicker() {
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        calendarCollectionView.collectionViewLayout = layout
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.backgroundColor = .clear
        
        calendarCollectionView.register(
            UINib(nibName: "JournalCalendarDateCell", bundle: nil),
            forCellWithReuseIdentifier: "JournalCalendarDateCell"
        )
    }
    
    func configure(with date: Date, journalDays: Set<Date>, selectedDay: Date?) {
        self.selectedDate = date
        self.journalDays = journalDays
        self.selectedDay = selectedDay
        updateMonthView()
    }
    
    func updateMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper.shared.daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper.shared.firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper.shared.weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        while count < startingSpaces {
            totalSquares.append("")
            count += 1
        }
        
        for i in 1...daysInMonth {
            totalSquares.append(String(i))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        monthLabel.text = dateFormatter.string(from: selectedDate)
        
        calendarCollectionView.reloadData()
        syncPickerToDate()
    }
    
    @IBAction func previousMonthTapped(_ sender: UIButton) {
        selectedDate = CalendarHelper.shared.minusMonth(date: selectedDate)
        updateMonthView()
        delegate?.calendarCell(self, didChangeTo: selectedDate)
    }
    
    @IBAction func nextMonthTapped(_ sender: UIButton) {
        selectedDate = CalendarHelper.shared.plusMonth(date: selectedDate)
        updateMonthView()
        delegate?.calendarCell(self, didChangeTo: selectedDate)
    }
    
    @IBAction func headerToggleTapped(_ sender: UIButton) {
        delegate?.calendarCellDidTapHeader(self)
        
        let isPickerVisible = !pickerContainerView.isHidden
        
        if isPickerVisible {
            // Hide picker, show calendar
            pickerContainerView.isHidden = true
            calendarCollectionView.isHidden = false
            monthLabel.textColor = .label
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = .identity
            }
        } else {
            // Show picker, hide calendar
            pickerContainerView.isHidden = false
            calendarCollectionView.isHidden = true
            monthLabel.textColor = UIColor(named: "PrimaryColor") ?? UIColor(red: 0.91, green: 0.42, blue: 0.57, alpha: 1.0)
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
            }
            syncPickerToDate()
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
}

// MARK: - UICollectionViewDataSource
extension JournalCalendarCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JournalCalendarCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        delegate?.calendarCell(self, didSelectDate: selected)
        calendarCollectionView.reloadData()
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension JournalCalendarCell: UIPickerViewDataSource, UIPickerViewDelegate {
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
            updateMonthView()
            delegate?.calendarCell(self, didChangeTo: newDate)
        }
    }
}

// MARK: - Calendar Helper
class CalendarHelper {
    static let shared = CalendarHelper()
    private let calendar = Calendar.current
    
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
