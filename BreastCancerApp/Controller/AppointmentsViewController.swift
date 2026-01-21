//
//  AppointmentsViewController.swift
//  Appointments
//
//  Created by Naman Bhansali on 11/01/26.
//

import UIKit

class AppointmentsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Navigation arrows
    @IBOutlet weak var previousMonth: UIButton!
    @IBOutlet weak var nextMonth: UIButton!
    
    // Picker Outlets
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var monthYearPicker: UIPickerView!
    
    // Header Interaction
    @IBOutlet weak var headerToggleButton: UIButton!
    @IBOutlet weak var chevronButton: UIButton!
    
    // Appointments List
    @IBOutlet weak var appointmentsContainerView: UIView! // Container that holds date header and table
    @IBOutlet weak var dateHeaderLabel: UILabel! // "Mon 30 Apr"
    @IBOutlet weak var appointmentsTableView: UITableView!
    @IBOutlet weak var addAppointmentButton: UIButton! // Pink + button
    
    // MARK: - Dynamic Height Constraint (ONLY TABLE VIEW)
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var selectedDate = Date()
    var viewingDate = Date()
    var totalSquares = [String]()
    var appointmentsForSelectedDate: [AppointmentItem] = []
    
    // Picker Data
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()
    
    // MARK: - Constants for Dynamic Height
    let cellHeight: CGFloat = 63
    let maxVisibleRows: Int = 2
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupYears()
        setupCollectionView()
        setupTableView()
        setupPicker()
        
        setMonthView()
        updateAppointmentsList(for: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setMonthView()
        updateAppointmentsList(for: viewingDate)
    }
    
    // MARK: - Setup Methods
    private func setupYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear - 10)...(currentYear + 10))
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "AppointmentDateCell", bundle: nil), forCellWithReuseIdentifier: "AppointmentDateCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    private func setupTableView() {
        appointmentsTableView.dataSource = self
        appointmentsTableView.delegate = self
        appointmentsTableView.separatorStyle = .none
        appointmentsTableView.separatorColor = .clear
        appointmentsTableView.separatorInset = .zero
        appointmentsTableView.isScrollEnabled = false
        appointmentsTableView.showsVerticalScrollIndicator = true
        appointmentsTableView.backgroundColor = .clear
        appointmentsTableView.isPagingEnabled = false
        appointmentsTableView.bounces = true
        appointmentsTableView.alwaysBounceVertical = false
        appointmentsTableView.contentInsetAdjustmentBehavior = .never
        appointmentsTableView.register(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "AppointmentCell")
    }
    
    private func setupPicker() {
        monthYearPicker.dataSource = self
        monthYearPicker.delegate = self
        pickerContainerView.isHidden = true
    }
    
    // MARK: - Calendar Methods
    private func setMonthView() {
        totalSquares.removeAll()
        let daysInMonth = AppointmentCalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = AppointmentCalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = AppointmentCalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count = 1
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
    
    private func updateAppointmentsList(for date: Date, reloadCalendar: Bool = true) {
        viewingDate = date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM"
        dateHeaderLabel.text = formatter.string(from: date)
        
        // Get appointments for this date from AppointmentManager
        appointmentsForSelectedDate = AppointmentManager.shared.getAppointments(for: date)
        
        // Sort appointments by time in ascending order (earliest first)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        appointmentsForSelectedDate.sort { appointment1, appointment2 in
            guard let time1 = timeFormatter.date(from: appointment1.time),
                  let time2 = timeFormatter.date(from: appointment2.time) else {
                return false
            }
            
            return time1 < time2 // Ascending order (earliest time first)
        }
        
        // Show/hide the appointments container based on whether there are appointments
        if appointmentsForSelectedDate.isEmpty {
            appointmentsContainerView.isHidden = true
        } else {
            appointmentsContainerView.isHidden = false
        }
        
        appointmentsTableView.reloadData()
        
        // Only reload calendar if needed
        if reloadCalendar {
            collectionView.reloadData()
        }
        
        updateCardHeight()
    }
    
    // MARK: - Dynamic Height Logic
    private func updateCardHeight() {
        // If hidden, no need to calculate
        guard !appointmentsContainerView.isHidden else { return }
        
        let numberOfItems = appointmentsForSelectedDate.count
        
        // Calculate table content height
        let tableContentHeight = CGFloat(numberOfItems) * cellHeight
        
        // Calculate maximum allowed height (3 rows)
        let maxTableHeight = CGFloat(maxVisibleRows) * cellHeight
        
        // Actual table height (minimum of content vs max allowed)
        let actualTableHeight = min(tableContentHeight, maxTableHeight)
        
        // Enable scrolling only if more than 3 appointments
        appointmentsTableView.isScrollEnabled = numberOfItems > maxVisibleRows
        appointmentsTableView.showsVerticalScrollIndicator = numberOfItems > maxVisibleRows
        
        // Update TableView Height Constraint
        if let tableConstraint = tableViewHeightConstraint {
            tableConstraint.constant = actualTableHeight
            print("able height set to: \(actualTableHeight)")
        } else {
            print("tableViewHeightConstraint is nil - NOT CONNECTED!")
        }
        
        let topToDateHeader: CGFloat = 15
        let dateHeaderHeight: CGFloat = 29
        let dateHeaderToTable: CGFloat = 7.67
        let bottomPadding: CGFloat = 0
        
        let totalContainerHeight = topToDateHeader + dateHeaderHeight + dateHeaderToTable + actualTableHeight + bottomPadding
        
        if let containerConstraint = containerHeightConstraint {
            containerConstraint.constant = totalContainerHeight
            print("✅ Container height set to: \(totalContainerHeight)")
        } else {
            print("❌ containerHeightConstraint is nil - NOT CONNECTED!")
        }
        
        // Animate the change
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        print("📊 Appointments: \(numberOfItems), Table: \(actualTableHeight), Container: \(totalContainerHeight)")
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
        selectedDate = AppointmentCalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonthTapped(_ sender: UIButton) {
        selectedDate = AppointmentCalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func addAppointmentTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Appointments", bundle: nil)
        if let navController = storyboard.instantiateViewController(withIdentifier: "NewAppointmentNavController") as? UINavigationController{
            if let addVC = navController.topViewController as? NewAppointmentViewController {
                addVC.delegate = self
            }
            navController.modalPresentationStyle = .pageSheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UICollectionView DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppointmentDateCell", for: indexPath) as! AppointmentDateCell
        let dayString = totalSquares[indexPath.item]
        
        var isSelected = false
        var hasAppointments = false
        var appointmentTypes: [AppointmentType] = []
        var isToday = false
        
        if let dayInt = Int(dayString) {
            let cal = Calendar.current
            var components = cal.dateComponents([.year, .month], from: selectedDate)
            components.day = dayInt
            
            if let cellDate = cal.date(from: components) {
                isSelected = cal.isDate(cellDate, inSameDayAs: viewingDate)
                isToday = cal.isDateInToday(cellDate)
                
                let appointments = AppointmentManager.shared.getAppointments(for: cellDate)
                hasAppointments = !appointments.isEmpty
                
                // Get unique appointment types for this date
                appointmentTypes = Array(Set(appointments.compactMap { $0.appointmentType }))
            }
        }
        
        cell.configure(day: dayString, isSelected: isSelected, hasAppointments: hasAppointments, appointmentTypes: appointmentTypes, isToday: isToday)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayString = totalSquares[indexPath.item]
        guard let dayInt = Int(dayString) else { return }
        
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month], from: selectedDate)
        components.day = dayInt
        
        if let newDate = cal.date(from: components) {
            // Check if this date has appointments
            let appointments = AppointmentManager.shared.getAppointments(for: newDate)
            
            // If no appointments, don't allow selection
            guard !appointments.isEmpty else {
                return
            }
            
            // Store old viewing date to find its cell
            let oldViewingDate = viewingDate
            
            // Update appointments list without reloading the entire calendar
            updateAppointmentsList(for: newDate, reloadCalendar: false)
            
            // Only reload the affected calendar cells (old and new selection)
            var cellsToReload: [IndexPath] = []
            
            // Find and reload old selected cell
            let oldDay = cal.component(.day, from: oldViewingDate)
            if let oldIndex = totalSquares.firstIndex(of: String(oldDay)) {
                cellsToReload.append(IndexPath(item: oldIndex, section: 0))
            }
            
            // Find and reload new selected cell
            if let newIndex = totalSquares.firstIndex(of: String(dayInt)) {
                cellsToReload.append(IndexPath(item: newIndex, section: 0))
            }
            
            // Reload only these specific cells
            if !cellsToReload.isEmpty {
                collectionView.reloadItems(at: cellsToReload)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 44)
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentsForSelectedDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
        cell.configure(with: appointmentsForSelectedDate[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // MARK: - Swipe Actions (Edit & Delete)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Check if the appointment date is in the past
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let viewingDay = calendar.startOfDay(for: viewingDate)
        
        // If viewing date is strictly before today, disable actions
        if viewingDay < today {
            return nil
        }
        
        // --- ACTION 1: DELETE (Red) ---
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            // Call the confirmation alert logic
            self?.confirmDelete(at: indexPath, completion: completionHandler)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        // --- ACTION 2: EDIT (Blue) ---
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let appointment = self.appointmentsForSelectedDate[indexPath.row]
            
            // Open edit screen
            let storyboard = UIStoryboard(name: "Appointments", bundle: nil)
            if let navController = storyboard.instantiateViewController(withIdentifier: "NewAppointmentNavController") as? UINavigationController{
                if let editVC = navController.topViewController as? NewAppointmentViewController {
                    editVC.delegate = self
                    editVC.initialAppointment = appointment
                }
                navController.modalPresentationStyle = .pageSheet
                if let sheet = navController.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
                self.present(navController, animated: true, completion: nil)
            }
            
            completionHandler(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    // MARK: - Delete Confirmation Logic
    func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        
        // Safely get the title/category for the alert message
        let appointment = appointmentsForSelectedDate[indexPath.row]
        let displayTitle = !appointment.title.isEmpty ? appointment.title : appointment.category
        
        let alert = UIAlertController(
            title: "Delete Appointment?",
            message: "Are you sure you want to delete '\(displayTitle)'?",
            preferredStyle: .alert
        )
        
        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // 1. Delete from Manager
            AppointmentManager.shared.deleteAppointment(appointment.id, for: self.viewingDate)
            
            // 2. Remove from local array
            self.appointmentsForSelectedDate.remove(at: indexPath.row)
            
            // 3. Delete row animation
            self.appointmentsTableView.deleteRows(at: [indexPath], with: .fade)
            
            // 4. Recalculate heights after deletion
            self.updateCardHeight()
            self.collectionView.reloadData()
            
            // 5. Hide container if no more appointments
            if self.appointmentsForSelectedDate.isEmpty {
                self.appointmentsContainerView.isHidden = true
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("AppointmentDataUpdated"), object: nil)

            
            completion(true)
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        
        alert.addAction(deleteBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true)
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

// MARK: - AddAppointmentDelegate
extension AppointmentsViewController: AddAppointmentDelegate {
    func didAddAppointment(_ appointment: AppointmentItem) {
        // Parse the date from the appointment's date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        if let appointmentDate = dateFormatter.date(from: appointment.date) {
            // Save appointment to the correct date
            AppointmentManager.shared.saveAppointment(appointment, for: appointmentDate)
            
            // Update the viewing date to the appointment's date
            viewingDate = appointmentDate
            
            // Update the selected month if the appointment is in a different month
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: selectedDate)
            let currentYear = calendar.component(.year, from: selectedDate)
            let appointmentMonth = calendar.component(.month, from: appointmentDate)
            let appointmentYear = calendar.component(.year, from: appointmentDate)
            
            if currentMonth != appointmentMonth || currentYear != appointmentYear {
                selectedDate = appointmentDate
                setMonthView()
            }
            
            updateAppointmentsList(for: appointmentDate)
            NotificationCenter.default.post(name: NSNotification.Name("AppointmentDataUpdated"), object: nil)

        }
    }
}
// MARK: - CalendarHelper
class AppointmentCalendarHelper {
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
