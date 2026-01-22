import UIKit

protocol ExerciseCalendarCellDelegate: AnyObject {
    func calendarCell(_ cell: ExerciseCalendarCell, didSelectDate date: Date)
    func calendarCell(_ cell: ExerciseCalendarCell, didChangeTo date: Date)
    func calendarCellDidTapHeader(_ cell: ExerciseCalendarCell)
}

class ExerciseCalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var headerToggleButton: UIButton!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    weak var delegate: ExerciseCalendarCellDelegate?
    
    var selectedDate = Date()
    private var selectedDay: Date?
    var totalSquares = [String]()
    var exerciseDays: Set<Date> = []
    
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
        years = Array((currentYear - 10)...currentYear)
    }
    
    private func setupPicker() {
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        calendarCollectionView.collectionViewLayout = layout
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.backgroundColor = .clear
        calendarCollectionView.isScrollEnabled = false
        
        calendarCollectionView.register(
            UINib(nibName: "ExerciseCalendarDateCell", bundle: nil),
            forCellWithReuseIdentifier: "ExerciseCalendarDateCell"
        )
    }
    
    func configure(with date: Date, exerciseDays: Set<Date>, selectedDay: Date?) {
        self.selectedDate = date
        self.exerciseDays = exerciseDays
        self.selectedDay = selectedDay
        updateMonthView()
    }
    
    func updateMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = ExerciseCalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = ExerciseCalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = ExerciseCalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count = 1
        while count < startingSpaces {
            totalSquares.append("")
            count += 1
        }
        
        for i in 1...daysInMonth {
            totalSquares.append(String(i))
        }
        
        // Pad to exactly 42 squares (6 rows)
        while totalSquares.count < 42 {
            totalSquares.append("")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: selectedDate)
        
        calendarCollectionView.reloadData()
        syncPickerToDate()
    }
    
    @IBAction func previousMonthTapped(_ sender: UIButton) {
        selectedDate = ExerciseCalendarHelper().minusMonth(date: selectedDate)
        updateMonthView()
        delegate?.calendarCell(self, didChangeTo: selectedDate)
    }
    
    @IBAction func nextMonthTapped(_ sender: UIButton) {
        let nextMonthDate = ExerciseCalendarHelper().plusMonth(date: selectedDate)
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        let nextYear = calendar.component(.year, from: nextMonthDate)
        let nextMonthValue = calendar.component(.month, from: nextMonthDate)
        
        if nextYear < currentYear || (nextYear == currentYear && nextMonthValue <= currentMonth) {
            selectedDate = nextMonthDate
            updateMonthView()
            delegate?.calendarCell(self, didChangeTo: selectedDate)
        }
    }
    
    @IBAction func headerToggleTapped(_ sender: UIButton) {
        delegate?.calendarCellDidTapHeader(self)
        
        let isPickerVisible = !pickerContainerView.isHidden
        
        if isPickerVisible {
            pickerContainerView.isHidden = true
            calendarCollectionView.isHidden = false
            monthLabel.textColor = .black
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = .identity
            }
        } else {
            pickerContainerView.isHidden = false
            calendarCollectionView.isHidden = true
            monthLabel.textColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
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
extension ExerciseCalendarCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ExerciseCalendarDateCell",
            for: indexPath
        ) as! ExerciseCalendarDateCell
        
        let dayString = totalSquares[indexPath.item]
        
        var hasPlan = false
        var isSelected = false
        var isToday = false
        var isFuture = false
        
        if let day = Int(dayString) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month], from: selectedDate)
            components.day = day
            
            if let date = calendar.date(from: components) {
                let normalized = calendar.startOfDay(for: date)
                
                hasPlan = exerciseDays.contains(normalized)
                isSelected = selectedDay.map {
                    calendar.isDate($0, inSameDayAs: normalized)
                } ?? false
                
                isToday = calendar.isDateInToday(normalized)
                isFuture = normalized > calendar.startOfDay(for: Date())
            }
        }
        
        cell.configure(
            day: dayString,
            isSelected: isSelected,
            hasPlan: hasPlan,
            isFuture: isFuture,
            isToday: isToday
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExerciseCalendarCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 44)
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
        
        // Prevent selection of future dates AND today
        if selected >= today { return }
        
        selectedDay = selected
        delegate?.calendarCell(self, didSelectDate: selected)
        calendarCollectionView.reloadData()
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension ExerciseCalendarCell: UIPickerViewDataSource, UIPickerViewDelegate {
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
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        if year == currentYear && monthIndex > currentMonth {
            pickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true)
            return
        }
        
        var components = DateComponents()
        components.year = year
        components.month = monthIndex
        components.day = 1
        
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
            updateMonthView()
            delegate?.calendarCell(self, didChangeTo: newDate)
        }
    }
}

// MARK: - ExerciseCalendarHelper
class ExerciseCalendarHelper {
    let calendar = Calendar.current
    
    func plusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func daysInMonth(date: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: date)!.count
    }
    
    func firstOfMonth(date: Date) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }
    
    func weekDay(date: Date) -> Int {
        return calendar.dateComponents([.weekday], from: date).weekday!
    }
}
