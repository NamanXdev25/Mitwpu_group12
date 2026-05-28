//
//  NewAddMedicationViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 20/03/26.
//

import UIKit

protocol NewAddMedicationDelegate: AnyObject {
    func didSaveMedications(_ medications: [Medication], editedId: String?)
}

private enum Section: Int, CaseIterable {
    case name = 0
    case repeat_ = 1
    case days = 2
    case time = 3
    case duration = 4
    case note = 5

    var header: String {
        switch self {
        case .name: return "Medication"
        case .repeat_: return "Repeat"
        case .days: return "Days"
        case .time: return "Time"
        case .duration: return "Duration"
        case .note: return "Notes"
        }
    }
}

private enum DurationRow: Int, CaseIterable {
    case startDate, endDate
}

class NewAddMedicationViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var saveButton: UIBarButtonItem!

    weak var delegate: NewAddMedicationDelegate?
    var medicationToEdit: Medication?

    private var nameText = ""
    private var isCustomRepeat = false
    private var selectedDays = Set<Int>()
    private var times = [Date]()
    private var startDate: Date?
    private var endDate: Date?
    private var endDateEnabled = false
    private var noteText = ""
    private var reminderOn = true

    private let nameCellID = "NewAppointmentTextFieldCell"
    private let repCellID = "MedicationRepetitionViewCell"
    private let daysCellID = "MedicationDaysCell"
    private let timeCellID = "MedicationTimeCell"
    private let addTimeCellID = "NewAppointmentReminderTimeCell"
    private let switchCellID = "NewAppointmentSwitchCell"
    private let dateCellID = "NewAppointmentDateTimeCell"
    private let noteCellID = "NewAppointmentNoteCell"

    private var reminderRow: Int {
        0
    }

    private var firstTimeRow: Int {
        1
    }

    private var addTimeRow: Int {
        1 + times.count
    }

    private var timeSectionCount: Int {
        1 + times.count + 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        loadEditingData()
        title = medicationToEdit == nil ? "Add Medication" : "Edit Medication"
    }

    private func registerCells() {
        [nameCellID, repCellID, daysCellID, timeCellID,
         addTimeCellID, switchCellID, dateCellID, noteCellID].forEach {
            collectionView.register(
                UINib(nibName: $0, bundle: nil),
                forCellWithReuseIdentifier: $0
            )
        }
        collectionView.register(
            UICollectionViewListCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "listHeader"
        )
    }

    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self else { return nil }
            let section = Section(rawValue: sectionIndex)!

            var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            listConfig.showsSeparators = true
            listConfig.backgroundColor = UIColor(named: "BackgroundColor")

            if section == .days && !self.isCustomRepeat {
                listConfig.headerMode = .none
                let emptySection = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
                emptySection.contentInsets = .zero
                return emptySection
            } else {
                listConfig.headerMode = .supplementary
            }

            return NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
        }
    }

    private func loadEditingData() {
        if let med = medicationToEdit {
            nameText = med.name
            noteText = med.note
            reminderOn = med.reminderEnabled

            if med.repeatOption == "Every Day" {
                isCustomRepeat = false
            } else {
                isCustomRepeat = true
                let mapping: [String: Int] = [
                    "Every Sun": 1, "Every Mon": 2, "Every Tue": 3,
                    "Every Wed": 4, "Every Thu": 5, "Every Fri": 6, "Every Sat": 7,
                ]
                if let wd = mapping[med.repeatOption] { selectedDays.insert(wd) }
            }

            let tf = DateFormatter()
            tf.dateFormat = "h:mm a"
            tf.locale = Locale(identifier: "en_US_POSIX")
            if let t = tf.date(from: med.time) { times.append(t) }
        } else {
            times.append(Date())
            selectedDays.insert(1)
        }
    }

    @IBAction func saveTapped(_: UIBarButtonItem) {
        view.endEditing(true)
        guard validate() else { return }
        delegate?.didSaveMedications(buildMedications(), editedId: medicationToEdit?.id)
        navigationController?.popViewController(animated: true)
    }

    private func validate() -> Bool {
        if nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert("Please enter a medication name."); return false
        }
        if isCustomRepeat && selectedDays.isEmpty {
            showAlert("Please select at least one day."); return false
        }
        if times.isEmpty {
            showAlert("Please add at least one time."); return false
        }
        return true
    }

    private func showAlert(_ msg: String) {
        let ac = UIAlertController(title: "Required Field", message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    private func buildMedications() -> [Medication] {
        let tf = DateFormatter()
        tf.timeStyle = .short

        let name = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        var durationSuffix = ""
        if let s = startDate {
            let df = DateFormatter(); df.dateFormat = "dd MMM yyyy"
            if endDateEnabled, let e = endDate {
                durationSuffix = " | \(df.string(from: s)) – \(df.string(from: e))"
            } else {
                durationSuffix = " | From \(df.string(from: s))"
            }
        }

        let dayMapping: [Int: String] = [
            1: "Every Sun", 2: "Every Mon", 3: "Every Tue",
            4: "Every Wed", 5: "Every Thu", 6: "Every Fri", 7: "Every Sat",
        ]
        let repeatOptions: [String] = isCustomRepeat
            ? selectedDays.sorted().compactMap { dayMapping[$0] }
            : ["Every Day"]

        let baseId = medicationToEdit?.id
        var result = [Medication]()

        for repeatOption in repeatOptions {
            for (i, timeDate) in times.enumerated() {
                result.append(Medication(
                    id: (
                        times.count == 1 && repeatOptions.count == 1 && i == 0
                            ? baseId : nil
                    ) ?? UUID().uuidString,
                    name: name,
                    note: noteText + durationSuffix,
                    time: tf.string(from: timeDate),
                    repeatOption: repeatOption,
                    isTaken: medicationToEdit?.isTaken ?? false,
                    reminderEnabled: reminderOn
                ))
            }
        }
        return result
    }

    private func insertTime(_ date: Date) {
        let newIndex = times.count
        times.append(date)
        let insertIP = IndexPath(item: firstTimeRow + newIndex, section: Section.time.rawValue)
        let addBtnIP = IndexPath(item: addTimeRow, section: Section.time.rawValue)
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [insertIP])
            collectionView.reloadItems(at: [addBtnIP])
        }
    }

    private func deleteTime(at index: Int) {
        times.remove(at: index)
        let removeIP = IndexPath(item: firstTimeRow + index, section: Section.time.rawValue)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [removeIP])
        }
    }
}

extension NewAddMedicationViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch Section(rawValue: section)! {
        case .name: return 1
        case .repeat_: return 1
        case .days: return isCustomRepeat ? 1 : 0
        case .time: return timeSectionCount
        case .duration: return DurationRow.allCases.count
        case .note: return 1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let section = Section(rawValue: indexPath.section)
        else {
            return UICollectionReusableView()
        }
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "listHeader", for: indexPath
        ) as? UICollectionViewListCell else {
            fatalError("Expected UICollectionViewListCell for reuse identifier 'listHeader'")
        }
        var config = UIListContentConfiguration.groupedHeader()
        config.text = section.header
        header.contentConfiguration = config
        return header
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch section {
        case .name: return configureNameCell(at: indexPath)
        case .repeat_: return configureRepeatCell(at: indexPath)
        case .days: return configureDaysCell(at: indexPath)
        case .time: return configureTimeCell(at: indexPath)
        case .duration: return configureDurationCell(at: indexPath)
        case .note: return configureNoteCell(at: indexPath)
        }
    }

    private func configureNameCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeue(nameCellID, at: indexPath) as? NewAppointmentTextFieldCell else {
            fatalError("Expected NewAppointmentTextFieldCell for reuse identifier '\(nameCellID)'")
        }
        cell.configure(placeholder: "Medication Name *", text: nameText)
        cell.onTextChange = { [weak self] in self?.nameText = $0 }
        return cell
    }

    private func configureRepeatCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeue(repCellID, at: indexPath) as? MedicationRepetitionViewCell else {
            fatalError("Expected MedicationRepetitionViewCell for reuse identifier '\(repCellID)'")
        }
        cell.configure(isCustom: isCustomRepeat)
        cell.onRepeatChanged = { [weak self] isCustom in
            guard let self else { return }
            let wasCustom = self.isCustomRepeat
            self.isCustomRepeat = isCustom
            if wasCustom != isCustom {
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadSections(
                        IndexSet(integer: Section.days.rawValue)
                    )
                }
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
        return cell
    }

    private func configureDaysCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeue(daysCellID, at: indexPath) as? MedicationDaysCell else {
            fatalError("Expected MedicationDaysCell for reuse identifier '\(daysCellID)'")
        }
        cell.configure(selectedDays: selectedDays)
        cell.onDaysChanged = { [weak self] days in self?.selectedDays = days }
        return cell
    }

    private func configureTimeCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.item
        if row == reminderRow {
            guard let cell = dequeue(switchCellID, at: indexPath) as? NewAppointmentSwitchCell else {
                fatalError("Expected NewAppointmentSwitchCell for reuse identifier '\(switchCellID)'")
            }
            cell.configure(isOn: reminderOn)
            cell.onToggle = { [weak self] on in self?.reminderOn = on }
            return cell
        } else if row == addTimeRow {
            guard let cell = dequeue(addTimeCellID, at: indexPath) as? NewAppointmentReminderTimeCell else {
                fatalError("Expected NewAppointmentReminderTimeCell for reuse identifier '\(addTimeCellID)'")
            }
            cell.isMedicationContext = true
            cell.onAdd = { [weak self] in self?.insertTime(Date()) }
            return cell
        } else {
            let timeIndex = row - firstTimeRow
            guard let cell = dequeue(timeCellID, at: indexPath) as? MedicationTimeCell else {
                fatalError("Expected MedicationTimeCell for reuse identifier '\(timeCellID)'")
            }
            cell.configure(time: times[timeIndex])
            cell.onDelete = { [weak self] in self?.deleteTime(at: timeIndex) }
            cell.onTimeChange = { [weak self] newDate in self?.times[timeIndex] = newDate }
            return cell
        }
    }

    private func configureDurationCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeue(dateCellID, at: indexPath) as? NewAppointmentDateTimeCell else {
            fatalError("Expected NewAppointmentDateTimeCell for reuse identifier '\(dateCellID)'")
        }
        guard let durationRow = DurationRow(rawValue: indexPath.item) else {
            return cell
        }
        switch durationRow {
        case .startDate:
            cell.configureAsStartDate(current: startDate)
            cell.onDateChange = { [weak self] d in self?.startDate = d }
        case .endDate:
            let defaultEnd = Calendar.current.date(
                byAdding: .month, value: 1, to: startDate ?? Date()
            ) ?? Date()
            cell.configureAsEndDate(date: endDate ?? defaultEnd, enabled: endDateEnabled)
            cell.onDateChange = { [weak self] d in self?.endDate = d }
            cell.onNoneTapped = { [weak self] in
                guard let self else { return }
                self.endDateEnabled = true
                self.endDate = Calendar.current.date(
                    byAdding: .month, value: 1, to: self.startDate ?? Date()
                )
                self.collectionView.reloadItems(at: [indexPath])
            }
            cell.onClearEndDate = { [weak self] in
                guard let self else { return }
                self.endDateEnabled = false
                self.endDate = nil
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        return cell
    }

    private func configureNoteCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeue(noteCellID, at: indexPath) as? NewAppointmentNoteCell else {
            fatalError("Expected NewAppointmentNoteCell for reuse identifier '\(noteCellID)'")
        }
        cell.configure(text: noteText)
        cell.onTextChange = { [weak self] in self?.noteText = $0 }
        return cell
    }

    private func dequeue(_ id: String, at ip: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: id, for: ip)
    }
}

extension NewAddMedicationViewController: UICollectionViewDelegate {
    func collectionView(
        _: UICollectionView,
        shouldHighlightItemAt _: IndexPath
    ) -> Bool {
        false
    }
}
