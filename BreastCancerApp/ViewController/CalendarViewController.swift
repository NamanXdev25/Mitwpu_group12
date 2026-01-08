import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    // --- OUTLETS ---
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    // Outlets for navigation arrows
    @IBOutlet weak var previousMonth: UIButton!
    @IBOutlet weak var nextMonth: UIButton!
    
    // Picker Outlets
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    // Header Interaction Outlets
    @IBOutlet weak var headerToggleButton: UIButton! // The invisible button over "Apr 2025"
    @IBOutlet weak var chevronButton: UIButton!      // The pink chevron >
    
    // Detail View Outlets
    @IBOutlet weak var statusLabel: UILabel!       // e.g. "2 of 5 Completed"
    @IBOutlet weak var selectedDateLabel: UILabel! // e.g. "Mon, Jan 5"
    @IBOutlet weak var missedHeaderLabel: UILabel! // Label saying "Missed"
    @IBOutlet weak var missedTableView: UITableView!
    
    // --- VARIABLES ---
    var selectedDate = Date()         // Month currently being displayed
    var viewingDate = Date()          // Specific date selected for the detail view
    var totalSquares = [String]()
    var missedItems: [PlanItem] = []
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupYears()
        setupCollectionView()
        setupTableView()
        
        // Picker Setup
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true // Hidden by default
        
        setMonthView()
        updateDetails(for: Date()) // Initialize with today's date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure we show latest status if something changed just now
        ExerciseManager.shared.updateHistoryForToday()
        setMonthView()
        updateDetails(for: viewingDate)
    }
    
    func setupYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...(currentYear + 10))
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CalendarDateCell", bundle: nil), forCellWithReuseIdentifier: "CalendarDateCell")
        
        // Ensure layout is flat
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    func setupTableView() {
        missedTableView.dataSource = self
        missedTableView.delegate = self
        missedTableView.separatorStyle = .none
        missedTableView.register(UINib(nibName: "MissedExerciseCell", bundle: nil), forCellReuseIdentifier: "MissedExerciseCell")
    }
    
    func setMonthView() {
        totalSquares.removeAll()
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count = 1
        while count < startingSpaces {
            totalSquares.append("")
            count += 1
        }
        for i in 1...daysInMonth { totalSquares.append(String(i)) }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: selectedDate)
        
        collectionView.reloadData()
        syncPickerToDate()
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
    
    func updateDetails(for date: Date) {
        viewingDate = date
        let key = ExerciseManager.shared.getDateKey(for: date)
        
        // 1. Update Date Label
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"
        selectedDateLabel.text = df.string(from: date)
        
        // 2. Fetch Progress from Manager
        if let progress = ExerciseManager.shared.history[key] {
            statusLabel.text = "\(progress.completedCount) of \(progress.total) Completed"
            missedItems = progress.missedItems
            missedHeaderLabel.isHidden = missedItems.isEmpty
        } else {
            statusLabel.text = "No exercises planned"
            missedItems = []
            missedHeaderLabel.isHidden = true
        }
        
        missedTableView.reloadData()
    }
    
    // --- ACTIONS ---
    
    @IBAction func headerToggleButton(_ sender: Any) {
        let isPickerVisible = !pickerContainerView.isHidden
        
        if isPickerVisible {
            pickerContainerView.isHidden = true
            collectionView.isHidden = false
            monthLabel.textColor = .black
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = .identity
            }
        } else {
            pickerContainerView.isHidden = false
            collectionView.isHidden = true
            monthLabel.textColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
            }
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
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // --- COLLECTION VIEW ---
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
        let dayString = totalSquares[indexPath.item]
        
        var isSelected = false
        var hasPlan = false
        
        if let dayInt = Int(dayString) {
            let cal = Calendar.current
            var components = cal.dateComponents([.year, .month], from: selectedDate)
            components.day = dayInt
            
            if let cellDate = cal.date(from: components) {
                isSelected = cal.isDate(cellDate, inSameDayAs: viewingDate)
                let key = ExerciseManager.shared.getDateKey(for: cellDate)
                hasPlan = ExerciseManager.shared.history[key] != nil
            }
        }
        
        cell.configure(day: dayString, isSelected: isSelected, hasPlan: hasPlan)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayString = totalSquares[indexPath.item]
        guard let dayInt = Int(dayString) else { return }
        
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month], from: selectedDate)
        components.day = dayInt
        
        if let newDate = cal.date(from: components) {
            updateDetails(for: newDate)
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 44)
    }

    // --- TABLE VIEW ---
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissedExerciseCell", for: indexPath) as! MissedExerciseCell
        cell.configure(with: missedItems[indexPath.row])
        return cell
    }

    // --- PICKER VIEW DELEGATE ---
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? months.count : years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? months[row] : String(years[row])
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
            setMonthView()
        }
    }
}

class CalendarHelper {
    let calendar = Calendar.current
    func plusMonth(date: Date) -> Date { return calendar.date(byAdding: .month, value: 1, to: date)! }
    func minusMonth(date: Date) -> Date { return calendar.date(byAdding: .month, value: -1, to: date)! }
    func daysInMonth(date: Date) -> Int { return calendar.range(of: .day, in: .month, for: date)!.count }
    func firstOfMonth(date: Date) -> Date { return calendar.date(from: calendar.dateComponents([.year, .month], from: date))! }
    func weekDay(date: Date) -> Int { return calendar.dateComponents([.weekday], from: date).weekday! }
}
