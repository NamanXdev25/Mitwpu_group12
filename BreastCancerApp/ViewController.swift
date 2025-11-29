//
//  ViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 19/11/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}



/*
 
 
 
 
 import UIKit

 class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

     @IBOutlet weak var nextMonth: UIButton!
     @IBOutlet weak var previousMonth: UIButton!
     @IBOutlet weak var monthLabel: UILabel!
     @IBOutlet weak var collectionView: UICollectionView!
     @IBOutlet weak var closeButton: UIButton!
     
     // Logic Variables
     var selectedDate = Date()
     var totalSquares = [String]()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // Style the View
         //self.view.backgroundColor = .white
         //self.view.layer.cornerRadius = 20
         
         // Setup Collection View
         let layout = UICollectionViewFlowLayout()
         layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
         layout.minimumLineSpacing = 0
         layout.minimumInteritemSpacing = 0
         collectionView.collectionViewLayout = layout
         
         collectionView.dataSource = self
         collectionView.delegate = self
         
         // Register Cell
         collectionView.register(UINib(nibName: "CalendarDateCell", bundle: nil), forCellWithReuseIdentifier: "CalendarDateCell")
         
         // Initial Setup
         setMonthView()
     }
     
     func setMonthView() {
         totalSquares.removeAll()
         
         let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
         let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
         let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
         
         // 1. Add empty spaces before the 1st of the month
         var count: Int = 1
         while(count < startingSpaces) {
             totalSquares.append("")
             count += 1
         }
         
         // 2. Add actual days
         for i in 1...daysInMonth {
             totalSquares.append(String(i))
         }
         
         // Update Title
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MMMM yyyy"
         monthLabel.text = dateFormatter.string(from: selectedDate)
         
         collectionView.reloadData()
     }
     
     // --- ACTIONS ---
     
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

     // --- COLLECTION VIEW DATA ---
     
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return totalSquares.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
         
         let dayString = totalSquares[indexPath.item]
         
         // --- LOGIC: SIMULATING DATA ---
         // Here you would check your database if exercises are done for this specific date.
         // For now, I'll simulate the pattern in your screenshot.
         
         var status = "none"
         
         if dayString == "20" {
             status = "selected" // Dark Pink (Selected Date)
         } else if let dayInt = Int(dayString), dayInt >= 13 && dayInt <= 18 {
             status = "completed" // Light Pink (Past activity)
         } else if let dayInt = Int(dayString), dayInt == 12 {
             status = "completed"
         }
         
         cell.configure(day: dayString, status: status)
         
         return cell
     }
     
     // --- SIZING: 7 Columns ---
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         // Screen width divided by 7 days
         let width = collectionView.frame.size.width / 7
         return CGSize(width: width, height: 40)
     }
 }

 // --- HELPER CLASS FOR DATE MATH ---
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
         return components.weekday! // 1 = Sunday, 2 = Monday...
     }
 }

 */

/*
import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nextMonth: UIButton!
    @IBOutlet weak var previousMonth: UIButton!
    // --- OUTLETS ---
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    
    // Picker Outlets
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    // CHANGED: Use UIButton instead of UIImageView for interaction
    @IBOutlet weak var chevronButton: UIButton!
    
    // --- VARIABLES ---
    var selectedDate = Date()
    var totalSquares = [String]()
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Generate Years
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...(currentYear + 10))
        
        // 2. Setup Picker
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        
        // 3. Setup Grid
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register Cell
        collectionView.register(UINib(nibName: "CalendarDateCell", bundle: nil), forCellWithReuseIdentifier: "CalendarDateCell")
        
        // 4. Initial State
        pickerContainerView.isHidden = true
        
        // Configure Chevron Button (Initial State)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronButton.setImage(image, for: .normal)
        chevronButton.tintColor = .systemPink
        
        setMonthView()
    }
    
    func setMonthView() {
        totalSquares.removeAll()
        
        // Using the Helper Class defined below
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: selectedDate)
        
        collectionView.reloadData()
        syncPickerToDate()
    }
    
    func syncPickerToDate() {
        let calendar = Calendar.current
        let monthIndex = calendar.component(.month, from: selectedDate) - 1
        let year = calendar.component(.year, from: selectedDate)
        
        if let yearIndex = years.firstIndex(of: year) {
            monthYearPicker.selectRow(monthIndex, inComponent: 0, animated: false)
            monthYearPicker.selectRow(yearIndex, inComponent: 1, animated: false)
        }
    }
    
    // --- ACTIONS ---
    
    // Connect this to the Chevron Button directly!
    @IBAction func togglePickerTapped(_ sender: Any) {
        let isPickerVisible = !pickerContainerView.isHidden
        
        if isPickerVisible {
            // HIDE Picker
            pickerContainerView.isHidden = true
            collectionView.isHidden = false
            monthLabel.textColor = .black
            
            // Rotate back
            UIView.animate(withDuration: 0.3) {
                self.chevronButton.transform = .identity
            }
        } else {
            // SHOW Picker
            pickerContainerView.isHidden = false
            collectionView.isHidden = true
            monthLabel.textColor = .systemBlue
            
            // Rotate down
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
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // --- DELEGATES ---
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
        let dayString = totalSquares[indexPath.item]
        
        var status = "none"
        if dayString == "20" { status = "selected" }
        else if let d = Int(dayString), d >= 13 && d <= 18 { status = "completed" }
        
        cell.configure(day: dayString, status: status)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 7
        return CGSize(width: width, height: 40)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 2 }
    
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
            // Note: We don't update setMonthView immediately to keep UI stable until closed
            // or update live if preferred.
        }
    }
}

// --- MISSING HELPER CLASS RESTORED ---
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

