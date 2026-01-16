//
//  MediactionCalendarViewController.swift
//  Medication
//
//  Created by Naman Bhansali on 15/01/26.
//
import UIKit

class MedicationCalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    // Navigation arrows
    @IBOutlet weak var previousMonth: UIButton!
    @IBOutlet weak var nextMonth: UIButton!
    
    // Picker Outlets
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    // Header Interaction
    @IBOutlet weak var headerToggleButton: UIButton!
    @IBOutlet weak var chevronButton: UIButton!
    
    // Detail View Outlets - Following CalendarViewController pattern
    @IBOutlet weak var statusLabel: UILabel!       // This will show: "Missed" or "All medications taken" or "No medications planned"
    @IBOutlet weak var missedTableView: UITableView!
    
    // Container and constraints
    @IBOutlet weak var detailCardView: UIView! // The card that contains all detail views
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint! // Height constraint for table
    @IBOutlet weak var detailCardHeightConstraint: NSLayoutConstraint! // Height constraint for entire card
    
    // MARK: - Properties
    var selectedDate = Date()         // Month currently being displayed
    var viewingDate = Date()          // Specific date selected for the detail view
    var totalSquares = [String]()
    var missedMedications: [Medication] = []
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    // MARK: - Constants for Dynamic Height
    let cellHeight: CGFloat = 30
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupYears()
        setupCollectionView()
        setupTableView()
        setupPicker()
        
        setMonthView()
        updateDetails(for: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setMonthView()
        updateDetails(for: viewingDate)
    }
    
    // MARK: - Setup Methods
    private func setupYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...currentYear) // Only up to current year
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MedicationDateCell", bundle: nil), forCellWithReuseIdentifier: "MedicationDateCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    private func setupTableView() {
        missedTableView.dataSource = self
        missedTableView.delegate = self
        missedTableView.separatorStyle = .none
        missedTableView.isScrollEnabled = false // Disable scrolling - height will adjust instead
        missedTableView.register(UINib(nibName: "MedicationCell", bundle: nil), forCellReuseIdentifier: "MedicationCell")
    }
    
    private func setupPicker() {
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true
    }
    
    // MARK: - Calendar Methods
    private func setMonthView() {
        totalSquares.removeAll()
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count = 1
        while count < startingSpaces {
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
    
    private func syncPickerToDate() {
        let calendar = Calendar.current
        let monthIndex = calendar.component(.month, from: selectedDate) - 1
        let year = calendar.component(.year, from: selectedDate)
        
        if let yearIndex = years.firstIndex(of: year) {
            monthYearPicker.selectRow(monthIndex, inComponent: 0, animated: false)
            monthYearPicker.selectRow(yearIndex, inComponent: 1, animated: false)
        }
    }
    
    private func updateDetails(for date: Date) {
        viewingDate = date
        
        // Check if selected date is today or in the future
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()
        
        // Hide entire card for today and future dates
        if isToday || isFuture {
            detailCardView?.isHidden = true
            return
        }
        
        // Show card for past dates
        detailCardView?.isHidden = false
        
        // Fetch medications history from Manager
        if let history = MedicationHistory.shared.getHistory(for: date) {
            // Medications were planned for this day
            let allMedications = history.medications
            missedMedications = allMedications.filter { !$0.isTaken }
            
            if missedMedications.isEmpty {
                // All medications taken
                statusLabel.text = "All medications taken"
                missedTableView.isHidden = true
            } else {
                // Some medications missed
                statusLabel.text = "Missed"
                missedTableView.isHidden = false
            }
        } else {
            // No medications planned for this day
            statusLabel.text = "No medications planned"
            missedMedications = []
            missedTableView.isHidden = true
        }
        
        // Update table view and adjust heights dynamically
        missedTableView.reloadData()
        updateCardHeight()
    }
    
    // MARK: - Dynamic Height Logic (Following CalendarViewController pattern)
    private func updateCardHeight() {
        let numberOfItems = missedMedications.count
        let tableHeight = CGFloat(numberOfItems) * cellHeight
        
        // Calculate max table height based on available screen space
        let screenHeight = UIScreen.main.bounds.height
        let availableHeight = screenHeight * 0.2  // Use max 20% of screen for table
        let maxTableHeight = min(availableHeight, CGFloat(6) * cellHeight)  // Cap at 6 cells or 20% screen
        
        let actualTableHeight = min(tableHeight, maxTableHeight)
        
        missedTableView.isScrollEnabled = numberOfItems > Int(maxTableHeight / cellHeight)
        
        tableViewHeightConstraint?.constant = actualTableHeight
        
        let topPadding: CGFloat = 8
        let statusLabelHeight: CGFloat = 30
        let statusToTableSpacing: CGFloat = 5
        let bottomPadding: CGFloat = 16
        
        let totalHeight: CGFloat
        if numberOfItems == 0 {
            totalHeight = topPadding + statusLabelHeight + bottomPadding
        } else {
            totalHeight = topPadding + statusLabelHeight + statusToTableSpacing + actualTableHeight + bottomPadding
        }
        
        detailCardHeightConstraint?.constant = totalHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - IBActions
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func headerToggleButtonTapped(_ sender: UIButton) {
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
    
    @IBAction func previousMonthTapped(_ sender: UIButton) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonthTapped(_ sender: UIButton) {
        let nextMonthDate = CalendarHelper().plusMonth(date: selectedDate)
        
        // Check if next month would be in the future
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        let nextYear = calendar.component(.year, from: nextMonthDate)
        let nextMonthValue = calendar.component(.month, from: nextMonthDate)
        
        // Only allow if next month is not in the future
        if nextYear < currentYear || (nextYear == currentYear && nextMonthValue <= currentMonth) {
            selectedDate = nextMonthDate
            setMonthView()
        }
        // If it would go to future, do nothing (button press is ignored)
    }
    
    // MARK: - UICollectionView DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationDateCell", for: indexPath) as! MedicationDateCell
        let dayString = totalSquares[indexPath.item]
        
        var isSelected = false
        var hasMedications = false
        var isFutureDate = false
        var isToday = false
        
        if let dayInt = Int(dayString) {
            let cal = Calendar.current
            var components = cal.dateComponents([.year, .month], from: selectedDate)
            components.day = dayInt
            
            if let cellDate = cal.date(from: components) {
                isSelected = cal.isDate(cellDate, inSameDayAs: viewingDate)
                isToday = cal.isDateInToday(cellDate)
                
                if let history = MedicationHistory.shared.getHistory(for: cellDate) {
                    hasMedications = !history.medications.isEmpty
                }
                
                // Check if date is in future (compared to today)
                isFutureDate = cellDate > Date()
            }
        }
        
        cell.configure(day: dayString, isSelected: isSelected, hasMedications: hasMedications, isFuture: isFutureDate, isToday: isToday)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayString = totalSquares[indexPath.item]
        guard let dayInt = Int(dayString) else { return }
        
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month], from: selectedDate)
        components.day = dayInt
        
        if let newDate = cal.date(from: components) {
            // Don't allow selecting future dates
            if newDate > Date() {
                return
            }
            
            // Don't allow selecting dates with no medications
            if MedicationHistory.shared.getHistory(for: newDate) == nil {
                return
            }
            
            updateDetails(for: newDate)
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 44)
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missedMedications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell", for: indexPath) as! MedicationCell
        let medication = missedMedications[indexPath.row]
        cell.configure(with: medication)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
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
        
        // Get current date components
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        // Don't allow selecting future months in current year
        if year == currentYear && monthIndex > currentMonth {
            // Reset to current month
            pickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true)
            return
        }
        
        var components = DateComponents()
        components.year = year
        components.month = monthIndex
        components.day = 1
        
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
            setMonthView()
        }
    }
}

// MARK: - CalendarHelper
class CalendarHelper {
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
