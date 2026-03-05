//
//  NewAppointmentViewController.swift
//  Appointments
//
//  Created by Naman Bhansali on 10/01/26.
//

import UIKit

// MARK: - Delegate
protocol AddAppointmentDelegate: AnyObject {
    func didAddAppointment(_ appointment: AppointmentItem)
}

// MARK: - Section / Row
private enum Section: Int, CaseIterable {
    case details  = 0   // Title, Doctor, Location
    case dateTime = 1   // Date, Time
    case reminder = 2   // Switch, ReminderTimes
    case note     = 3
}

private enum DetailsRow: Int, CaseIterable  { case title, doctor, location }
private enum DateTimeRow: Int, CaseIterable { case date, time }
private enum ReminderRow: Int, CaseIterable { case toggle, times }

// MARK: - ViewController
class NewAppointmentViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: Public
    weak var delegate: AddAppointmentDelegate?
    var initialAppointment: AppointmentItem?
    var originalDate: Date?

    // MARK: State
    private var titleText    = ""
    private var doctorText   = ""
    private var locationText = ""
    private var selectedDate: Date?
    private var selectedTime: Date?
    private var reminderOn   = true
    private var reminderOffsets: [ReminderOffset] = [.day1]
    private var userNoteText = ""

    // MARK: Cell IDs  — must match XIB file names exactly
    private let tfCellID  = "NewAppointmentTextFieldCell"
    private let dtCellID  = "NewAppointmentDateTimeCell"
    private let swCellID  = "NewAppointmentSwitchCell"
    private let remCellID = "NewAppointmentReminderTimeCell"
    private let noteCellID = "NewAppointmentNoteCell"

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.keyboardDismissMode = .onDrag
        loadInitialData()
    }

    // MARK: Setup
    private func registerCells() {
        [tfCellID, dtCellID, swCellID, remCellID, noteCellID].forEach {
            collectionView.register(UINib(nibName: $0, bundle: nil),
                                    forCellWithReuseIdentifier: $0)
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.showsSeparators = true
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    // MARK: Load existing data
    private func loadInitialData() {
        guard let a = initialAppointment else { return }

        titleText       = a.title
        reminderOn      = a.reminderEnabled
        reminderOffsets = a.reminderOffsets.isEmpty ? [.day1] : a.reminderOffsets

        // Parse doctor / location back out of note
        // Stored format: "doctor | location\nnote"
        let note = a.note
        if let newlineRange = note.range(of: "\n") {
            let header = String(note[note.startIndex..<newlineRange.lowerBound])
            userNoteText   = String(note[newlineRange.upperBound...])
            let parts      = header.components(separatedBy: " | ")
            doctorText     = parts.indices.contains(0) ? parts[0] : ""
            locationText   = parts.indices.contains(1) ? parts[1] : ""
        } else {
            userNoteText = note
        }

        let df = DateFormatter(); df.dateFormat = "dd MMM yyyy"
        if let d = df.date(from: a.date) { selectedDate = d; originalDate = d }

        let tf = DateFormatter(); tf.dateFormat = "h:mm a"
        if let t = tf.date(from: a.time) { selectedTime = t }
    }

    // MARK: Nav bar IBActions
//    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
//        dismiss(animated: true)
//    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard validate() else { return }

        if let old = initialAppointment,
           let oldDate = originalDate,
           let newDate = selectedDate,
           !Calendar.current.isDate(oldDate, inSameDayAs: newDate) {
            AppointmentManager.shared.deleteAppointment(old.id, for: oldDate)
        }

        delegate?.didAddAppointment(buildItem())
        dismiss(animated: true)
    }

    // MARK: Validation
    private func validate() -> Bool {
        if titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alert("Please enter a title."); return false
        }
        if selectedDate == nil {
            alert("Please select a date."); return false
        }
        if selectedTime == nil {
            alert("Please select a time."); return false
        }
        return true
    }

    private func alert(_ msg: String) {
        let ac = UIAlertController(title: "Required Field", message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // MARK: Build model
    private func buildItem() -> AppointmentItem {
        let doctor   = doctorText.trimmingCharacters(in: .whitespacesAndNewlines)
        let location = locationText.trimmingCharacters(in: .whitespacesAndNewlines)

        var combinedNote = userNoteText
        if !doctor.isEmpty || !location.isEmpty {
            let header = [doctor, location].filter { !$0.isEmpty }.joined(separator: " | ")
            combinedNote = userNoteText.isEmpty ? header : "\(header)\n\(userNoteText)"
        }

        return AppointmentItem(
            id: initialAppointment?.id ?? UUID().uuidString,
            title: titleText,
            category: "",
            date: selectedDate.map { fmtDate($0) } ?? "",
            time: selectedTime.map { fmtTime($0) } ?? "",
            reminderEnabled: reminderOn,
            reminderOffsets: reminderOffsets,
            note: combinedNote,
            colorIndex: 0
        )
    }

    // MARK: Formatters
    private func fmtDate(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd MMM yyyy"; return f.string(from: d)
    }
    private func fmtTime(_ d: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: d)
    }

    // MARK: Reminder popup
    private func presentReminderPopup() {
        let ac = UIAlertController(title: "Add Reminder", message: nil, preferredStyle: .actionSheet)
        for offset in ReminderOffset.allCases {
            let added  = reminderOffsets.contains(offset)
            let action = UIAlertAction(title: offset.rawValue, style: .default) { [weak self] _ in
                guard let self, !added else { return }
                self.reminderOffsets.append(offset)
                self.reloadReminderTimesCell()
            }
            action.isEnabled = !added
            ac.addAction(action)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    private func reloadReminderTimesCell() {
        let ip = IndexPath(item: ReminderRow.times.rawValue,
                           section: Section.reminder.rawValue)
        collectionView.reloadItems(at: [ip])
    }
}

// MARK: - DataSource
extension NewAppointmentViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .details:  return DetailsRow.allCases.count
        case .dateTime: return DateTimeRow.allCases.count
        case .reminder: return ReminderRow.allCases.count
        case .note:     return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch Section(rawValue: indexPath.section)! {

        case .details:
            let cell = dequeue(tfCellID, collectionView, indexPath) as! NewAppointmentTextFieldCell
            switch DetailsRow(rawValue: indexPath.item)! {
            case .title:
                cell.configure(placeholder: "Title *", text: titleText)
                cell.onTextChange = { [weak self] in self?.titleText = $0 }
            case .doctor:
                cell.configure(placeholder: "Doctor / Department", text: doctorText)
                cell.onTextChange = { [weak self] in self?.doctorText = $0 }
            case .location:
                cell.configure(placeholder: "Location", text: locationText)
                cell.onTextChange = { [weak self] in self?.locationText = $0 }
            }
            return cell

        case .dateTime:
            let cell = dequeue(dtCellID, collectionView, indexPath) as! NewAppointmentDateTimeCell
            switch DateTimeRow(rawValue: indexPath.item)! {
            case .date:
                cell.configureAsDate(current: selectedDate)
                cell.datePicker.addTarget(self,
                    action: #selector(datePickerChanged(_:)), for: .valueChanged)
            case .time:
                cell.configureAsTime(current: selectedTime)
                cell.datePicker.addTarget(self,
                    action: #selector(timePickerChanged(_:)), for: .valueChanged)
            }
            return cell

        case .reminder:
            switch ReminderRow(rawValue: indexPath.item)! {
            case .toggle:
                let cell = dequeue(swCellID, collectionView, indexPath) as! NewAppointmentSwitchCell
                cell.configure(isOn: reminderOn)
                cell.onToggle = { [weak self] on in self?.reminderOn = on }
                return cell
            case .times:
                let cell = dequeue(remCellID, collectionView, indexPath) as! NewAppointmentReminderTimeCell
                cell.reminderOffsets = reminderOffsets
                cell.onAdd    = { [weak self] in self?.presentReminderPopup() }
                cell.onDelete = { [weak self] idx in
                    guard let self else { return }
                    self.reminderOffsets.remove(at: idx)
                    self.reloadReminderTimesCell()
                }
                return cell
            }

        case .note:
            let cell = dequeue(noteCellID, collectionView, indexPath) as! NewAppointmentNoteCell
            cell.configure(text: userNoteText)
            cell.onTextChange = { [weak self] in self?.userNoteText = $0 }
            return cell
        }
    }

    // Convenience
    private func dequeue(_ id: String,
                         _ cv: UICollectionView,
                         _ ip: IndexPath) -> UICollectionViewCell {
        cv.dequeueReusableCell(withReuseIdentifier: id, for: ip)
    }

    // MARK: Picker targets
    @objc private func datePickerChanged(_ picker: UIDatePicker) {
        selectedDate = picker.date
    }
    @objc private func timePickerChanged(_ picker: UIDatePicker) {
        selectedTime = picker.date
    }
}

// MARK: - Delegate
extension NewAppointmentViewController: UICollectionViewDelegate {
    // Compact UIDatePicker handles its own taps — no didSelectItemAt needed.
    // Disable row highlight so rows don't flash when tapped.
    func collectionView(_ collectionView: UICollectionView,
                        shouldHighlightItemAt indexPath: IndexPath) -> Bool { false }
}
