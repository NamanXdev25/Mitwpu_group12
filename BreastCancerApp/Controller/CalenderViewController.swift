//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Shloka Shetty on 3/12/25.
//
import UIKit

struct CalendarDay {
    let goal: Int
    let taken: Int
    var isSelected: Bool
}

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
    var monthData: [String: CalendarDay] = [:]
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    func getDate(day: Int) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        components.day = day
        return Calendar.current.date(from: components)
    }
    
    struct CalendarDay {
        let goal: Int
        let taken: Int
        var isSelected: Bool
    }
    
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
        
       generateHybridData(daysInMonth: daysInMonth)
        
        
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
    
    // HYBRID DATA: Mock History + Real Today
        func generateHybridData(daysInMonth: Int) {
            monthData.removeAll()
            
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: selectedDate) // 1-12
            let currentYear = calendar.component(.year, from: selectedDate)   // 2025
            
            // Get Today's Real Date components to compare
            let today = Date()
            let realDay = calendar.component(.day, from: today)
            let realMonth = calendar.component(.month, from: today)
            let realYear = calendar.component(.year, from: today)
            
            for i in 1...daysInMonth {
                let dayString = String(i)
                
                // Default Variables
                var goal = 4
                var taken = 0
                var isSelected = false
                
                // --- LOGIC START ---
                
                // 1. IS IT TODAY? (Use Real Data)
                if currentYear == realYear && currentMonth == realMonth && i == realDay {
                    // Fetch from the real database we created
                    // (Note: ensure you have the MedicationHistory class from the previous steps)
                    let progress = MedicationHistory.shared.getProgress(for: today)
                    if progress.goal > 0 {
                        goal = progress.goal
                        taken = progress.taken
                    } else {
                        // Default if no pills added yet today
                        goal = 4
                        taken = 0
                    }
                    // Mark as selected so it looks active
                    isSelected = true
                }
                
                // 2. IS IT THE FUTURE? (Empty)
                else if (currentYear > realYear) || (currentYear == realYear && currentMonth > realMonth) || (currentYear == realYear && currentMonth == realMonth && i > realDay) {
                    // Future dates: Goal exists (planning), but Taken is 0
                    goal = 4
                    taken = 0
                }
                
                // 3. IS IT THE PAST? (Use Dummy Data for visuals)
                else {
                    // A. NOVEMBER 2025 (The "Mixed" Month)
                    if currentMonth == 11 && currentYear == 2025 {
                        if i % 3 == 0 { taken = 2 } // Every 3rd day: "Some Missed" (Light Pink)
                        else { taken = 4 }          // Others: "All Taken" (Dark Pink)
                    }
                    
                    // B. DECEMBER 2025 (Past days only)
                    else if currentMonth == 12 && currentYear == 2025 {
                        if i <= 5 { taken = 4 }        // Days 1-5: Perfect
                        else if i <= 10 { taken = 2 }  // Days 6-10: Struggled
                        else { taken = 3 }             // Day 11+: Mostly good
                    }
                    
                    // C. OLDER MONTHS (e.g., Oct) - Optional, keep empty or random
                    else {
                        taken = 0
                    }
                }
                
                // --- SAVE TO DICTIONARY ---
                let data = CalendarDay(goal: goal, taken: taken, isSelected: isSelected)
                monthData[dayString] = data
            }
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
            
            // 1. Calculate "Is Today"
            let currentDay = Calendar.current.component(.day, from: Date())
            let currentMonth = Calendar.current.component(.month, from: Date())
            let displayMonth = Calendar.current.component(.month, from: selectedDate)
            
            // It is today if the number matches AND the month matches
            let isToday = (dayString == String(currentDay)) && (currentMonth == displayMonth)
            
            // 2. Fetch Data
            if let data = monthData[dayString] {
                cell.configure(
                    day: dayString,
                    isToday: isToday,          //Pass the new flag
                    isSelected: data.isSelected,
                    takenCount: data.taken,
                    goalCount: data.goal
                )
            } else {
                cell.configure(
                    day: dayString,
                    isToday: isToday,          //Pass the new flag
                    isSelected: false,
                    takenCount: 0,
                    goalCount: 0
                )
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
