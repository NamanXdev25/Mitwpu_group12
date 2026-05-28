import UIKit

protocol AddAppointmentDelegate: AnyObject {
    func didAddAppointment(_ appointment: AppointmentItem)
}

private enum Section: Int, CaseIterable {
    case details = 0
    case dateTime = 1
    case reminder = 2
    case note = 3
}

private enum DetailsRow: Int, CaseIterable { case title, doctor, location }
private enum DateTimeRow: Int, CaseIterable { case date, time }

private let reminderToggleRow = 0
private func reminderOffsetRow(_ idx: Int) -> Int {
    idx + 1
}

class NewAppointmentViewController: UIViewController {
    @IBOutlet var backbutton: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var rightBarButton: UIBarButtonItem!

    weak var delegate: AddAppointmentDelegate?
    var initialAppointment: AppointmentItem?
    var originalDate: Date?

    var isViewMode: Bool = false

    // MARK: Private state

    private var isEditing_: Bool = false
    private var titleText = ""
    private var doctorText = ""
    private var locationText = ""
    private var selectedDate: Date?
    private var selectedTime: Date?
    private var reminderOn = true
    private var reminderOffsets: [ReminderOffset] = [.day1]
    private var userNoteText = ""

    private let tfCellID = "NewAppointmentTextFieldCell"
    private let dtCellID = "NewAppointmentDateTimeCell"
    private let swCellID = "NewAppointmentSwitchCell"
    private let remCellID = "NewAppointmentReminderTimeCell"
    private let addedReminderCellID = "NewAppintmentAddedReminderCell"
    private let noteCellID = "NewAppointmentNoteCell"

    private var reminderSectionCount: Int {
        1 + reminderOffsets.count + 1
    }

    private var addButtonRow: Int {
        reminderOffsets.count + 1
    }

    private var fieldsEnabled: Bool {
        return !isViewMode || isEditing_
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        registerCells()
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        loadInitialData()
        configureBarButton()
    }

    // MARK: Setup

    private func registerCells() {
        for item in [tfCellID, dtCellID, swCellID, remCellID, addedReminderCellID, noteCellID] {
            collectionView.register(
                UINib(nibName: item, bundle: nil),
                forCellWithReuseIdentifier: item
            )
        }
    }

    private func configureNavigationBar() {
        backbutton.target = self
        backbutton.action = #selector(backTapped(_:))
    }

    private func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.showsSeparators = true
        config.backgroundColor = UIColor(named: "BackgroundColor")
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    private func configureBarButton() {
        if isViewMode {
            rightBarButton.image = UIImage(systemName: "pencil")
            rightBarButton.tintColor = .white
            rightBarButton.title = nil
        } else {
            rightBarButton.image = UIImage(systemName: "checkmark")
            rightBarButton.tintColor = UIColor(named: "primary_color")
            rightBarButton.title = nil
        }
    }

    // MARK: Load existing data

    private func loadInitialData() {
        guard let a = initialAppointment else { return }
        titleText = a.title
        reminderOn = a.reminderEnabled
        reminderOffsets = a.reminderOffsets.isEmpty ? [.day1] : a.reminderOffsets

        let note = a.note
        if let newlineRange = note.range(of: "\n") {
            let header = String(note[note.startIndex ..< newlineRange.lowerBound])
            userNoteText = String(note[newlineRange.upperBound...])
            let parts = header.components(separatedBy: " | ")
            doctorText = parts.indices.contains(0) ? parts[0] : ""
            locationText = parts.indices.contains(1) ? parts[1] : ""
        } else {
            let parts = note.components(separatedBy: " | ")
            if parts.count > 1 {
                doctorText = parts.indices.contains(0) ? parts[0] : ""
                locationText = parts.indices.contains(1) ? parts[1] : ""
                userNoteText = ""
            } else {
                userNoteText = note
            }
        }

        let df = DateFormatter(); df.dateFormat = "dd MMM yyyy"
        if let d = df.date(from: a.date) { selectedDate = d; originalDate = d }

        let tf = DateFormatter(); tf.dateFormat = "h:mm a"
        if let t = tf.date(from: a.time) { selectedTime = t }
    }

    // MARK: Bar button action — handles both Edit and Save

    @IBAction func saveTapped(_: UIBarButtonItem) {
        if isViewMode, !isEditing_ {
            isEditing_ = true
            rightBarButton.image = UIImage(systemName: "checkmark")
            rightBarButton.tintColor = UIColor(named: "primary_color")
            rightBarButton.title = nil
            collectionView.reloadData()
            return
        }

        view.endEditing(true)
        guard validate() else { return }

        if let old = initialAppointment,
           let oldDate = originalDate,
           let newDate = selectedDate,
           !Calendar.current.isDate(oldDate, inSameDayAs: newDate) {
            AppointmentManager.shared.deleteAppointment(old.id, for: oldDate)
        }

        delegate?.didAddAppointment(buildItem())

        if initialAppointment == nil {
            CoinRewardService.shared.awardAppointmentCoinsIfEligible(on: self)
        }

        closeScreenAfterSave()
    }

    @objc private func backTapped(_: UIBarButtonItem) {
        if let navigationController, navigationController.viewControllers.first != self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func closeScreenAfterSave() {
        if let navigationController, navigationController.viewControllers.first != self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: Validation

    private func validate() -> Bool {
        if titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alert("Please enter a title."); return false
        }
        if selectedDate == nil { alert("Please select a date."); return false }
        if selectedTime == nil { alert("Please select a time."); return false }
        return true
    }

    private func alert(_ msg: String) {
        let ac = UIAlertController(title: "Required Field", message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // MARK: Build model

    private func buildItem() -> AppointmentItem {
        let doctor = doctorText.trimmingCharacters(in: .whitespacesAndNewlines)
        let location = locationText.trimmingCharacters(in: .whitespacesAndNewlines)
        var combinedNote = userNoteText
        if !doctor.isEmpty || !location.isEmpty {
            let header = [doctor, location].filter { !$0.isEmpty }.joined(separator: " | ")
            combinedNote = userNoteText.isEmpty ? header : "\(header)\n\(userNoteText)"
        }
        return AppointmentItem(
            id: initialAppointment?.id ?? UUID().uuidString,
            title: titleText,
            date: selectedDate.map { fmtDate($0) } ?? "",
            time: selectedTime.map { fmtTime($0) } ?? "",
            reminderEnabled: reminderOn,
            reminderOffsets: reminderOffsets,
            note: combinedNote
        )
    }

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
            let added = reminderOffsets.contains(offset)
            let action = UIAlertAction(title: offset.rawValue, style: .default) { [weak self] _ in
                guard let self, !added else { return }
                self.insertReminderOffset(offset)
            }
            action.isEnabled = !added
            ac.addAction(action)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = ac.popoverPresentationController {
            let ip = IndexPath(item: addButtonRow, section: Section.reminder.rawValue)
            if let cell = collectionView.cellForItem(at: ip) {
                popover.sourceView = cell
                popover.sourceRect = CGRect(
                    x: cell.bounds.midX,
                    y: cell.bounds.midY,
                    width: 0,
                    height: 0
                )
            } else {
                popover.sourceView = view
                popover.sourceRect = CGRect(
                    x: view.bounds.midX,
                    y: view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
        }
        present(ac, animated: true)
    }

    private func insertReminderOffset(_ offset: ReminderOffset) {
        let newIndex = reminderOffsets.count
        reminderOffsets.append(offset)
        let newRowIndex = reminderOffsetRow(newIndex)
        let insertIP = IndexPath(item: newRowIndex, section: Section.reminder.rawValue)
        let addBtnIP = IndexPath(item: newRowIndex + 1, section: Section.reminder.rawValue)
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [insertIP])
            collectionView.reloadItems(at: [addBtnIP])
        }
    }

    private func deleteReminderOffset(at index: Int) {
        reminderOffsets.remove(at: index)
        let removeIP = IndexPath(item: reminderOffsetRow(index), section: Section.reminder.rawValue)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [removeIP])
        }
    }
}

// MARK: - DataSource

extension NewAppointmentViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .details: return DetailsRow.allCases.count
        case .dateTime: return DateTimeRow.allCases.count
        case .reminder: return reminderSectionCount
        case .note: return 1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch sectionType {
        case .details:
            guard let cell = dequeue(tfCellID, collectionView, indexPath) as? NewAppointmentTextFieldCell else {
                fatalError("Expected NewAppointmentTextFieldCell for '\(tfCellID)' at \(indexPath)")
            }
            guard let detailsRow = DetailsRow(rawValue: indexPath.item) else { return cell }
            switch detailsRow {
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
            cell.textField.isUserInteractionEnabled = fieldsEnabled
            cell.textField.alpha = fieldsEnabled ? 1.0 : 0.4
            return cell

        case .dateTime:
            guard let cell = dequeue(dtCellID, collectionView, indexPath) as? NewAppointmentDateTimeCell else {
                fatalError("Expected NewAppointmentDateTimeCell for '\(dtCellID)' at \(indexPath)")
            }
            guard let dateTimeRow = DateTimeRow(rawValue: indexPath.item) else { return cell }
            switch dateTimeRow {
            case .date:
                cell.configureAsDate(current: selectedDate)
                cell.onDateChange = { [weak self] in self?.selectedDate = $0 }
            case .time:
                cell.configureAsTime(current: selectedTime)
                cell.onDateChange = { [weak self] in self?.selectedTime = $0 }
            }
            cell.datePicker.isUserInteractionEnabled = fieldsEnabled
            cell.datePicker.alpha = fieldsEnabled ? 1.0 : 0.4
            cell.titleLabel.alpha = fieldsEnabled ? 1.0 : 0.4
            return cell

        case .reminder:
            let row = indexPath.item

            if row == reminderToggleRow {
                guard let cell = dequeue(swCellID, collectionView, indexPath) as? NewAppointmentSwitchCell else {
                    fatalError("Expected NewAppointmentSwitchCell for '\(swCellID)' at \(indexPath)")
                }
                cell.configure(isOn: reminderOn)
                cell.onToggle = { [weak self] on in self?.reminderOn = on }
                return cell

            } else if row == addButtonRow {
                guard let cell = dequeue(remCellID, collectionView, indexPath) as? NewAppointmentReminderTimeCell else {
                    fatalError("Expected NewAppointmentReminderTimeCell for '\(remCellID)' at \(indexPath)")
                }
                cell.onAdd = { [weak self] in self?.presentReminderPopup() }
                return cell

            } else {
                let offsetIndex = row - 1
                guard let cell = dequeue(addedReminderCellID, collectionView, indexPath) as? NewAppintmentAddedReminderCell else {
                    fatalError("Expected NewAppintmentAddedReminderCell for '\(addedReminderCellID)' at \(indexPath)")
                }
                cell.configure(offset: reminderOffsets[offsetIndex])
                cell.onDelete = { [weak self] in
                    self?.deleteReminderOffset(at: offsetIndex)
                }
                return cell
            }

        case .note:
            guard let cell = dequeue(noteCellID, collectionView, indexPath) as? NewAppointmentNoteCell else {
                fatalError("Expected NewAppointmentNoteCell for '\(noteCellID)' at \(indexPath)")
            }
            cell.configure(text: userNoteText)
            cell.onTextChange = { [weak self] in self?.userNoteText = $0 }
            cell.noteTextView.isUserInteractionEnabled = fieldsEnabled
            return cell
        }
    }

    private func dequeue(
        _ id: String,
        _ cv: UICollectionView,
        _ ip: IndexPath
    ) -> UICollectionViewCell {
        cv.dequeueReusableCell(withReuseIdentifier: id, for: ip)
    }
}

// MARK: - Delegate

extension NewAppointmentViewController: UICollectionViewDelegate {
    func collectionView(
        _: UICollectionView,
        shouldHighlightItemAt _: IndexPath
    ) -> Bool {
        false
    }
}
