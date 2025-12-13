//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 27/11/25.
//
/*
 
 import UIKit
 
 class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {
 
 // --- OUTLETS ---
 @IBOutlet weak var monthLabel: UILabel!
 @IBOutlet weak var collectionView: UICollectionView!
 @IBOutlet weak var closeButton: UIButton!
 
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
 var totalSquares = [String]()
 
 // Picker Data
 let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
 var years = [Int]()
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
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
 setMonthView()
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
 monthLabel.textColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0) // Dark Pink
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
 
 // --- COLLECTION VIEW DELEGATE ---
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 return totalSquares.count
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
 let dayString = totalSquares[indexPath.item]
 
 // Reset state
 cell.configure(day: dayString, status: "none")
 
 if !dayString.isEmpty {
 // --- LOGIC: PINK INTENSITY ---
 // 1. Define the base pink color (The same pink used throughout)
 let basePink = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
 
 // 2. Check if it is TODAY (Simulated as "20" for now based on your screenshot)
 if dayString == "20" {
 // 100% Intensity for Today
 cell.selectionLayer.backgroundColor = basePink
 cell.dayLabel.textColor = .white
 }
 // 3. Check for "All Exercises Completed" (Simulated for days 12, 13, 14)
 else if ["12", "13", "14"].contains(dayString) {
 // 90% Intensity
 cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.6)
 cell.dayLabel.textColor = .white // or black, depending on contrast
 }
 // 4. Check for "Missed Exercises" (Simulated for days 16, 17, 18)
 else if ["16", "17", "18"].contains(dayString) {
 // Fixed Intensity (e.g., 40%) for missed tasks
 cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.2)
 cell.dayLabel.textColor = .black
 }
 }
 
 return cell
 }
 
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 let width = collectionView.frame.size.width / 7
 return CGSize(width: width, height: 40)
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
 
 */

//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 27/11/25.
//

/*
import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {

    // --- OUTLETS ---
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    
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
    var totalSquares = [String]()
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // selectedDate is initialized to Date() (Today) by default
        setMonthView()
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
            monthLabel.textColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0) // Dark Pink
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

    // --- COLLECTION VIEW DELEGATE ---
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
            let dayString = totalSquares[indexPath.item]
            
            // Reset state
            cell.configure(day: dayString, status: "none")
            
            if !dayString.isEmpty {
                // --- LOGIC: PINK INTENSITY ---
                // 1. Define the base pink color (The same pink used throughout)
                let basePink = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
                
                // Determine if the day displayed is TODAY
                let calendar = Calendar.current
                let currentDay = calendar.component(.day, from: Date())
                let currentMonth = calendar.component(.month, from: Date())
                let currentYear = calendar.component(.year, from: Date())
                
                let displayedMonth = calendar.component(.month, from: selectedDate)
                let displayedYear = calendar.component(.year, from: selectedDate)
                
                let isToday = (Int(dayString) == currentDay) && (displayedMonth == currentMonth) && (displayedYear == currentYear)
                
                // 2. Check if it is TODAY
                if isToday {
                    // 100% Intensity for Today
                    cell.selectionLayer.backgroundColor = basePink
                    cell.dayLabel.textColor = .white
                }
                // 3. Dummy Data for "All Exercises Completed" (e.g., 12, 13, 14 of current month)
                // Only show dummy data if we are in December (simulating "this month")
                else if displayedMonth == 12 && ["2", "7", "9"].contains(dayString) {
                    // 90% Intensity
                    cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.6)
                    cell.dayLabel.textColor = .white
                }
                // 4. Dummy Data for "Missed Exercises" (e.g., 16, 17, 18 of current month)
                else if displayedMonth == 12 && ["1", "11", "12"].contains(dayString) {
                    // Fixed Intensity (e.g., 40%) for missed tasks
                    cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.2)
                    cell.dayLabel.textColor = .black
                }
            }
            
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 7
        return CGSize(width: width, height: 40)
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

*/

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
    @IBOutlet weak var closeButton: UIButton!
    
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
    var totalSquares = [String]()
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // selectedDate is initialized to Date() (Today) by default
        setMonthView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure we show latest status if something changed just now
        ExerciseManager.shared.updateHistoryForToday()
        collectionView.reloadData()
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
            monthLabel.textColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0) // Dark Pink
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

    // --- COLLECTION VIEW DELEGATE ---
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
            let dayString = totalSquares[indexPath.item]
            
            // 1. Reset cell
            cell.configure(day: dayString, status: "none")
            
            if !dayString.isEmpty, let dayInt = Int(dayString) {
                
                // 2. Determine Date Key for this cell
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month], from: selectedDate)
                components.day = dayInt
                
                // Base Pink Color
                let basePink = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
                
                if let cellDate = calendar.date(from: components) {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let dateKey = formatter.string(from: cellDate)
                    
                    // --- UPDATED LOGIC ---
                    
                    // Is this TODAY?
                    if calendar.isDateInToday(cellDate) {
                        // Logic: "Today's date should have Dark pink circle only"
                        // Check if there is ANY plan for today
                        let manager = ExerciseManager.shared
                        if manager.todaysPlan.count > 0 {
                            // Active Plan -> Solid Dark Pink (No progress indication yet)
                            cell.selectionLayer.backgroundColor = basePink
                            cell.dayLabel.textColor = .white
                        } else {
                            // No Plan -> Empty
                            cell.selectionLayer.backgroundColor = .clear
                            cell.dayLabel.textColor = .black
                        }
                    }
                    // Is this a PAST date?
                    else if cellDate < Date() {
                        // Logic: "all this data should get updated on next day"
                        // Check History
                        if let progress = ExerciseManager.shared.history[dateKey] {
                            if progress.total > 0 {
                                if progress.completed == progress.total {
                                    // ALL DONE -> Solid Dark Pink
                                    // "more exercise circle"
                                    cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.6)
                                    cell.dayLabel.textColor = .black
                                } else {
                                    // PARTIAL / MISSED -> Light Pink
                                    // "less exercise circle"
                                    cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.2)
                                    cell.dayLabel.textColor = .black
                                }
                            } else {
                                // No exercises recorded for this past day
                                cell.selectionLayer.backgroundColor = .clear
                                cell.dayLabel.textColor = .black
                            }
                        }
                        // Fallback for Dummy Data (December Demo only) if no real history exists
                        else {
                            let displayedMonth = calendar.component(.month, from: selectedDate)
                            if displayedMonth == 12 {
                                 if ["12", "10", "8"].contains(dayString) {
                                    cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.6)
                                    cell.dayLabel.textColor = .black
                                } else if ["9", "11", "6"].contains(dayString) {
                                    cell.selectionLayer.backgroundColor = basePink.withAlphaComponent(0.2)
                                    cell.dayLabel.textColor = .black
                                }
                            }
                        }
                    }
                    // FUTURE dates
                    else {
                        cell.selectionLayer.backgroundColor = .clear
                        cell.dayLabel.textColor = .black
                    }
                }
            }
            
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 7
        return CGSize(width: width, height: 40)
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            monthLabel.text = dateFormatter.string(from: selectedDate)
        }
    }
}

// --- HELPER CLASS ---
class CalendarHelper {
    let calendar = Calendar.current
    func plusMonth(date: Date) -> Date { return calendar.date(byAdding: .month, value: 1, to: date)! }
    func minusMonth(date: Date) -> Date { return calendar.date(byAdding: .month, value: -1, to: date)! }
    func daysInMonth(date: Date) -> Int { return calendar.range(of: .day, in: .month, for: date)!.count }
    func firstOfMonth(date: Date) -> Date { return calendar.date(from: calendar.dateComponents([.year, .month], from: date))! }
    func weekDay(date: Date) -> Int { return calendar.dateComponents([.weekday], from: date).weekday! }
}
