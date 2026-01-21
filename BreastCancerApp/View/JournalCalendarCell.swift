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
    
    weak var delegate: JournalCalendarCellDelegate?
    
    var selectedDate = Date()
    private var selectedDay: Date?
    var totalSquares = [String]()
    var journalDays: Set<Date> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
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
