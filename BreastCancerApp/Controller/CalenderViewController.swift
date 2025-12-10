//
//  CalendarViewController.swift
//  BreastCancerApp
//
//  Created by Shloka Shetty on 3/12/25.
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
