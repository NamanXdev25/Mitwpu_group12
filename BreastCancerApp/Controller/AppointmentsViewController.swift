import UIKit

class AppointmentsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate,
    UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - Outlets

    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cancelbutton: UIBarButtonItem!
    @IBOutlet var previousMonth: UIButton!
    @IBOutlet var nextMonth: UIButton!

    @IBOutlet var pickerContainerView: UIView!
    @IBOutlet var monthYearPicker: UIPickerView!

    @IBOutlet var headerToggleButton: UIButton!
    @IBOutlet var chevronButton: UIButton!

    @IBOutlet var appointmentsContainerView: UIView!
    @IBOutlet var dateHeaderLabel: UILabel!
    @IBOutlet var appointmentsTableView: UITableView!

    // MARK: - Dynamic Height Constraint

    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var containerHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties

    var selectedDate = Date()
    var viewingDate = Date()
    var totalSquares = [String]()
    var appointmentsForSelectedDate: [AppointmentItem] = []

    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var years = [Int]()

    // MARK: - Constants for Dynamic Height

    let cellHeight: CGFloat = 63
    let maxVisibleRows: Int = 2

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
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
        years = Array((currentYear - 10) ... (currentYear + 10))
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

    private func configureNavigationBar() {
        cancelbutton.target = self
        cancelbutton.action = #selector(cancelTapped(_:))
    }

    private func makeNewAppointmentViewController() -> NewAppointmentViewController? {
        let storyboard = UIStoryboard(name: "Appointments", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "NewAppointmentViewController") as? NewAppointmentViewController
    }

    private func showAppointmentEditor(
        initialAppointment: AppointmentItem? = nil,
        isViewMode: Bool = false
    ) {
        guard let appointmentVC = makeNewAppointmentViewController() else { return }
        appointmentVC.delegate = self
        appointmentVC.initialAppointment = initialAppointment
        appointmentVC.isViewMode = isViewMode
        navigationController?.pushViewController(appointmentVC, animated: true)
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

        for i in 1 ... daysInMonth {
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

        appointmentsForSelectedDate = AppointmentManager.shared.getAppointments(for: date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        appointmentsForSelectedDate.sort { a1, a2 in
            guard let t1 = timeFormatter.date(from: a1.time),
                  let t2 = timeFormatter.date(from: a2.time) else { return false }
            return t1 < t2
        }

        appointmentsContainerView.isHidden = appointmentsForSelectedDate.isEmpty
        appointmentsTableView.reloadData()

        if reloadCalendar { collectionView.reloadData() }

        updateCardHeight()
    }

    // MARK: - Dynamic Height Logic

    private func updateCardHeight() {
        guard !appointmentsContainerView.isHidden else { return }

        let numberOfItems = appointmentsForSelectedDate.count
        let tableContentHeight = CGFloat(numberOfItems) * cellHeight
        let maxTableHeight = CGFloat(maxVisibleRows) * cellHeight
        let actualTableHeight = min(tableContentHeight, maxTableHeight)

        appointmentsTableView.isScrollEnabled = numberOfItems > maxVisibleRows
        appointmentsTableView.showsVerticalScrollIndicator = numberOfItems > maxVisibleRows

        if let tableConstraint = tableViewHeightConstraint {
            tableConstraint.constant = actualTableHeight
        }

        let topToDateHeader: CGFloat = 15
        let dateHeaderHeight: CGFloat = 29
        let dateHeaderToTable: CGFloat = 7.67
        let bottomPadding: CGFloat = 0
        let totalContainerHeight = topToDateHeader + dateHeaderHeight + dateHeaderToTable + actualTableHeight + bottomPadding

        if let containerConstraint = containerHeightConstraint {
            containerConstraint.constant = totalContainerHeight
        }

        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    // MARK: - IBActions

    @IBAction func headerToggleButtonTapped(_: UIButton) {
        let isPickerVisible = !pickerContainerView.isHidden

        if isPickerVisible {
            pickerContainerView.isHidden = true
            collectionView.isHidden = false
            monthLabel.textColor = .black
            UIView.animate(withDuration: 0.3) { self.chevronButton.transform = .identity }
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

    @IBAction func previousMonthTapped(_: UIButton) {
        selectedDate = AppointmentCalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }

    @IBAction func nextMonthTapped(_: UIButton) {
        selectedDate = AppointmentCalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }

    @IBAction func addAppointmentTapped(_: UIBarButtonItem) {
        showAppointmentEditor()
    }

    @objc private func cancelTapped(_: UIBarButtonItem) {
        dismiss(animated: true)
    }

    // MARK: - UICollectionView DataSource & Delegate

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return totalSquares.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppointmentDateCell", for: indexPath) as? AppointmentDateCell else {
            fatalError("Expected AppointmentDateCell for reuse identifier 'AppointmentDateCell'")
        }
        let dayString = totalSquares[indexPath.item]

        var isSelected = false
        var hasAppointments = false
        var isToday = false

        if let dayInt = Int(dayString) {
            let cal = Calendar.current
            var components = cal.dateComponents([.year, .month], from: selectedDate)
            components.day = dayInt

            if let cellDate = cal.date(from: components) {
                isSelected = cal.isDate(cellDate, inSameDayAs: viewingDate)
                isToday = cal.isDateInToday(cellDate)
                hasAppointments = AppointmentManager.shared.hasAppointments(for: cellDate)
            }
        }

        cell.configure(day: dayString, isSelected: isSelected, hasAppointments: hasAppointments, isToday: isToday)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayString = totalSquares[indexPath.item]
        guard let dayInt = Int(dayString) else { return }

        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month], from: selectedDate)
        components.day = dayInt

        if let newDate = cal.date(from: components) {
            let appointments = AppointmentManager.shared.getAppointments(for: newDate)
            guard !appointments.isEmpty else { return }

            let oldViewingDate = viewingDate
            updateAppointmentsList(for: newDate, reloadCalendar: false)

            var cellsToReload: [IndexPath] = []
            let oldDay = cal.component(.day, from: oldViewingDate)
            if let oldIndex = totalSquares.firstIndex(of: String(oldDay)) {
                cellsToReload.append(IndexPath(item: oldIndex, section: 0))
            }
            if let newIndex = totalSquares.firstIndex(of: String(dayInt)) {
                cellsToReload.append(IndexPath(item: newIndex, section: 0))
            }
            if !cellsToReload.isEmpty {
                collectionView.reloadItems(at: cellsToReload)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 44)
    }

    // MARK: - UITableView DataSource & Delegate

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return appointmentsForSelectedDate.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentCell else {
            fatalError("Expected AppointmentCell for reuse identifier 'AppointmentCell'")
        }
        cell.configure(with: appointmentsForSelectedDate[indexPath.row])
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let appointment = appointmentsForSelectedDate[indexPath.row]
        showAppointmentEditor(initialAppointment: appointment, isViewMode: true)
    }

    // MARK: - Swipe Actions (Edit & Delete)

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let viewingDay = calendar.startOfDay(for: viewingDate)

        if viewingDay < today { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.confirmDelete(at: indexPath, completion: completionHandler)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            guard let self else { return }
            let appointment = self.appointmentsForSelectedDate[indexPath.row]
            self.showAppointmentEditor(initialAppointment: appointment)
            completionHandler(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    // MARK: - Delete Confirmation

    func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let appointment = appointmentsForSelectedDate[indexPath.row]
        let displayTitle = appointment.title

        let alert = UIAlertController(
            title: "Delete Appointment?",
            message: "Are you sure you want to delete '\(displayTitle)'?",
            preferredStyle: .alert
        )

        let deleteBtn = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            AppointmentManager.shared.deleteAppointment(appointment.id, for: self.viewingDate)
            self.appointmentsForSelectedDate.remove(at: indexPath.row)
            self.appointmentsTableView.deleteRows(at: [indexPath], with: .fade)
            self.updateCardHeight()
            self.collectionView.reloadData()
            if self.appointmentsForSelectedDate.isEmpty {
                self.appointmentsContainerView.isHidden = true
            }
            NotificationCenter.default.post(name: NSNotification.Name("AppointmentDataUpdated"), object: nil)
            completion(true)
        }

        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in completion(false) }

        alert.addAction(deleteBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true)
    }

    // MARK: - UIPickerView DataSource & Delegate

    func numberOfComponents(in _: UIPickerView) -> Int {
        2
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? months.count : years.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? months[row] : String(years[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow _: Int, inComponent _: Int) {
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"

        if let appointmentDate = dateFormatter.date(from: appointment.date) {
            AppointmentManager.shared.saveAppointment(appointment, for: appointmentDate)
            viewingDate = appointmentDate

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
        calendar.date(byAdding: .month, value: 1, to: date) ?? date
    }

    func minusMonth(date: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }

    func daysInMonth(date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }

    func firstOfMonth(date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    func weekDay(date: Date) -> Int {
        calendar.dateComponents([.weekday], from: date).weekday ?? 1
    }
}
