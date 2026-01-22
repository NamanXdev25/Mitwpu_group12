//import UIKit
//
//class MedicationCalendarViewController: UIViewController {
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var closeBarButton: UIBarButtonItem!
//    
//    // Properties tracking state
//    var selectedDate = Date()
//    private var selectedDay: Date?
//    private var missedMedications: [Medication] = []
//    private var completedMedications: [Medication] = []
//    private var medicationDays: Set<Date> = []
//    private var showCenteredMessage = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        loadMedicationDays()
//        
//        // Default to showing yesterday's data on launch
//        let calendar = Calendar.current
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date())) ?? Date()
//        updateDataForDate(yesterday)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadMedicationDays()
//        collectionView.reloadData()
//        adjustBottomInset()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        adjustBottomInset()
//    }
//    
//    private func adjustBottomInset() {
//        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 49
//        let extraPadding: CGFloat = 20
//        collectionView.contentInset.bottom = tabBarHeight + extraPadding
//        collectionView.verticalScrollIndicatorInsets.bottom = tabBarHeight + extraPadding
//    }
//    
//    private func loadMedicationDays() {
//        medicationDays.removeAll()
//        let historyEntries = MedicationHistory.shared.getAllHistory()
//        let calendar = Calendar.current
//        
//        for entry in historyEntries {
//            let normalized = calendar.startOfDay(for: entry.date)
//            medicationDays.insert(normalized)
//        }
//    }
//    
//    private func setupCollectionView() {
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        
//        // REUSING SHARED EXERCISE COMPONENTS
//        collectionView.register(UINib(nibName: "ExerciseCalendarCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseCalendarCell")
//        collectionView.register(UINib(nibName: "CenteredMessageCell", bundle: nil), forCellWithReuseIdentifier: "CenteredMessageCell")
//        collectionView.register(UINib(nibName: "ExerciseSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ExerciseSectionHeader")
//        
//        // USING THE NEW STATS CELL TO AVOID CONFLICT WITH MedicationItemCell
//        collectionView.register(UINib(nibName: "MedicationStatsCell", bundle: nil), forCellWithReuseIdentifier: "MedicationStatsCell")
//        
//        collectionView.collectionViewLayout = createLayout()
//    }
//    
//    private func createLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) -> NSCollectionLayoutSection? in
//            guard let self = self else { return nil }
//            
//            if sectionIndex == 0 {
//                return self.createCalendarSection()
//            } else if self.showCenteredMessage && sectionIndex == 1 {
//                return self.createCenteredMessageSection()
//            } else {
//                let hasItems = sectionIndex == 1 ? !self.missedMedications.isEmpty : !self.completedMedications.isEmpty
//                let hasHeader = self.shouldShowHeader(for: sectionIndex)
//                return self.createMedicationItemsSection(hasItems: hasItems, hasHeader: hasHeader)
//            }
//        }
//    }
//    
//    // MARK: - Layout Sections (Logic matched with CalendarViewController)
//    private func createCalendarSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(350))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(350))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
//        
//        return section
//    }
//
//    private func createCenteredMessageSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
//        
//        return section
//    }
//
//    private func createMedicationItemsSection(hasItems: Bool, hasHeader: Bool) -> NSCollectionLayoutSection {
//        let height: CGFloat = hasItems ? 35 : 0.01 // Matched with CalendarViewController height
//        
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 0
//        
//        let headerHeight: NSCollectionLayoutDimension = hasHeader ? .estimated(44) : .absolute(0.01)
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: headerHeight)
//        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//        
//        if hasHeader || hasItems {
//            section.boundarySupplementaryItems = [header]
//        }
//        
//        let bottomInset: CGFloat = hasItems ? 16 : 0
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: bottomInset, trailing: 16)
//        
//        return section
//    }
//    
//    private func shouldShowHeader(for section: Int) -> Bool {
//        if showCenteredMessage { return false }
//        if section == 1 { return !missedMedications.isEmpty }
//        if section == 2 { return !completedMedications.isEmpty }
//        return false
//    }
//
//    private func updateDataForDate(_ date: Date) {
//        selectedDay = date
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let normalizedSelectedDate = calendar.startOfDay(for: date)
//        
//        // Logic: Stats only available for past dates (yesterday and earlier)
//        if normalizedSelectedDate >= today {
//            missedMedications = []
//            completedMedications = []
//            showCenteredMessage = true
//            collectionView.reloadData()
//            collectionView.collectionViewLayout.invalidateLayout()
//            return
//        }
//        
//        if let history = MedicationHistory.shared.getHistory(for: date) {
//            let timeFormatter = DateFormatter()
//            timeFormatter.dateFormat = "h:mm a"
//            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
//            
//            // AM/PM aware sorting in ascending order for both lists
//            let sortedMeds = history.medications.sorted { med1, med2 in
//                if let date1 = timeFormatter.date(from: med1.time),
//                   let date2 = timeFormatter.date(from: med2.time) {
//                    return date1 < date2
//                }
//                return med1.time < med2.time
//            }
//            
//            missedMedications = sortedMeds.filter { !$0.isTaken }
//            completedMedications = sortedMeds.filter { $0.isTaken }
//            showCenteredMessage = (missedMedications.isEmpty && completedMedications.isEmpty)
//        } else {
//            missedMedications = []
//            completedMedications = []
//            showCenteredMessage = true
//        }
//        collectionView.reloadData()
//        collectionView.collectionViewLayout.invalidateLayout()
//    }
//
//    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
//        dismiss(animated: true)
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//extension MedicationCalendarViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return showCenteredMessage ? 2 : 3
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 0 { return 1 }
//        if showCenteredMessage && section == 1 { return 1 }
//        if section == 1 { return missedMedications.count }
//        return completedMedications.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.section == 0 {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCalendarCell", for: indexPath) as! ExerciseCalendarCell
//            cell.configure(with: selectedDate, exerciseDays: medicationDays, selectedDay: selectedDay)
//            cell.delegate = self
//            cell.backgroundColor = .white
//            cell.layer.cornerRadius = 12
//            cell.layer.masksToBounds = true
//            return cell
//        }
//        
//        if showCenteredMessage && indexPath.section == 1 {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredMessageCell", for: indexPath) as! CenteredMessageCell
//            
//            let calendar = Calendar.current
//            let today = calendar.startOfDay(for: Date())
//            let selected = selectedDay != nil ? calendar.startOfDay(for: selectedDay!) : today
//            
//            if selected >= today {
//                cell.configure(message: "Stats will be available tomorrow")
//            } else {
//                cell.configure(message: "No medications scheduled for this day")
//            }
//            return cell
//        }
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationStatsCell", for: indexPath) as! MedicationStatsCell
//        let med = indexPath.section == 1 ? missedMedications[indexPath.item] : completedMedications[indexPath.item]
//        let count = indexPath.section == 1 ? missedMedications.count : completedMedications.count
//        
//        cell.configure(with: med, isFirst: indexPath.item == 0, isLast: indexPath.item == count - 1)
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExerciseSectionHeader", for: indexPath) as! ExerciseSectionHeader
//        if indexPath.section == 1 {
//            header.configure(status: "Missed")
//        } else if indexPath.section == 2 {
//            header.configure(status: "Taken")
//        }
//        return header
//    }
//}
//
//// MARK: - ExerciseCalendarCellDelegate
//extension MedicationCalendarViewController: ExerciseCalendarCellDelegate {
//    func calendarCell(_ cell: ExerciseCalendarCell, didSelectDate date: Date) {
//        updateDataForDate(date)
//    }
//    
//    func calendarCell(_ cell: ExerciseCalendarCell, didChangeTo date: Date) {
//        selectedDate = date
//        selectedDay = nil
//        showCenteredMessage = false
//        collectionView.reloadData()
//    }
//    
//    func calendarCellDidTapHeader(_ cell: ExerciseCalendarCell) {}
//}
//
//extension MedicationCalendarViewController: UICollectionViewDelegate {}

import UIKit

class MedicationCalendarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    // Properties tracking state
    var selectedDate = Date()
    private var selectedDay: Date?
    private var missedMedications: [Medication] = []
    private var completedMedications: [Medication] = []
    private var medicationDays: Set<Date> = []
    private var showCenteredMessage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadMedicationDays()
        
        // Ensure no date is selected by default on launch
        selectedDay = nil
        showCenteredMessage = false
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedicationDays()
        collectionView.reloadData()
        adjustBottomInset()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustBottomInset()
    }
    
    private func adjustBottomInset() {
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 49
        let extraPadding: CGFloat = 20
        collectionView.contentInset.bottom = tabBarHeight + extraPadding
        collectionView.verticalScrollIndicatorInsets.bottom = tabBarHeight + extraPadding
    }
    
    private func loadMedicationDays() {
        medicationDays.removeAll()
        let historyEntries = MedicationHistory.shared.getAllHistory()
        let calendar = Calendar.current
        
        for entry in historyEntries {
            let normalized = calendar.startOfDay(for: entry.date)
            medicationDays.insert(normalized)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // REUSING SHARED EXERCISE COMPONENTS
        collectionView.register(UINib(nibName: "ExerciseCalendarCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseCalendarCell")
        collectionView.register(UINib(nibName: "CenteredMessageCell", bundle: nil), forCellWithReuseIdentifier: "CenteredMessageCell")
        collectionView.register(UINib(nibName: "ExerciseSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ExerciseSectionHeader")
        
        // USING THE NEW STATS CELL
        collectionView.register(UINib(nibName: "MedicationStatsCell", bundle: nil), forCellWithReuseIdentifier: "MedicationStatsCell")
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            if sectionIndex == 0 {
                return self.createCalendarSection()
            } else if self.showCenteredMessage && sectionIndex == 1 {
                return self.createCenteredMessageSection()
            } else {
                let hasItems = sectionIndex == 1 ? !self.missedMedications.isEmpty : !self.completedMedications.isEmpty
                let hasHeader = self.shouldShowHeader(for: sectionIndex)
                return self.createMedicationItemsSection(hasItems: hasItems, hasHeader: hasHeader)
            }
        }
    }
    
    // MARK: - Layout Sections (Synchronized with CalendarViewController)
    private func createCalendarSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(386))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(386))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }

    private func createCenteredMessageSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }

    private func createMedicationItemsSection(hasItems: Bool, hasHeader: Bool) -> NSCollectionLayoutSection {
        let height: CGFloat = hasItems ? 35 : 0.01 // Identical height to ExerciseItemCell
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        
        let headerHeight: NSCollectionLayoutDimension = hasHeader ? .estimated(44) : .absolute(0.01)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: headerHeight)
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        if hasHeader || hasItems {
            section.boundarySupplementaryItems = [header]
        }
        
        let bottomInset: CGFloat = hasItems ? 16 : 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: bottomInset, trailing: 16)
        
        return section
    }
    
    private func shouldShowHeader(for section: Int) -> Bool {
        if showCenteredMessage || selectedDay == nil { return false }
        if section == 1 { return !missedMedications.isEmpty }
        if section == 2 { return !completedMedications.isEmpty }
        return false
    }

    private func updateDataForDate(_ date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let normalizedSelectedDate = calendar.startOfDay(for: date)
        
        // Blocking selection for today and future dates
        if normalizedSelectedDate >= today {
            // Though cells are non-tappable, this logic handles the data state safely
            selectedDay = normalizedSelectedDate
            missedMedications = []
            completedMedications = []
            showCenteredMessage = true
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
            return
        }
        
        selectedDay = normalizedSelectedDate
        
        if let history = MedicationHistory.shared.getHistory(for: date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Strictly AM/PM aware sorting in ascending order
            let sortedMeds = history.medications.sorted { med1, med2 in
                if let date1 = timeFormatter.date(from: med1.time),
                   let date2 = timeFormatter.date(from: med2.time) {
                    return date1 < date2
                }
                return med1.time < med2.time
            }
            
            missedMedications = sortedMeds.filter { !$0.isTaken }
            completedMedications = sortedMeds.filter { $0.isTaken }
            showCenteredMessage = (missedMedications.isEmpty && completedMedications.isEmpty)
        } else {
            missedMedications = []
            completedMedications = []
            showCenteredMessage = true
        }
        
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MedicationCalendarViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if selectedDay == nil { return 1 } // Only show calendar if nothing is selected
        return showCenteredMessage ? 2 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if showCenteredMessage && section == 1 { return 1 }
        if section == 1 { return missedMedications.count }
        return completedMedications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCalendarCell", for: indexPath) as! ExerciseCalendarCell
            cell.configure(with: selectedDate, exerciseDays: medicationDays, selectedDay: selectedDay)
            cell.delegate = self
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell
        }
        
        if showCenteredMessage && indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredMessageCell", for: indexPath) as! CenteredMessageCell
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            if let selected = selectedDay, selected >= today {
                cell.configure(message: "Stats will be available tomorrow")
            } else {
                cell.configure(message: "No medications scheduled for this day")
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationStatsCell", for: indexPath) as! MedicationStatsCell
        let med = indexPath.section == 1 ? missedMedications[indexPath.item] : completedMedications[indexPath.item]
        let count = indexPath.section == 1 ? missedMedications.count : completedMedications.count
        
        cell.configure(with: med, isFirst: indexPath.item == 0, isLast: indexPath.item == count - 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExerciseSectionHeader", for: indexPath) as! ExerciseSectionHeader
        if indexPath.section == 1 {
            header.configure(status: "Missed")
        } else if indexPath.section == 2 {
            header.configure(status: "Taken")
        }
        return header
    }
}

// MARK: - ExerciseCalendarCellDelegate
extension MedicationCalendarViewController: ExerciseCalendarCellDelegate {
    func calendarCell(_ cell: ExerciseCalendarCell, didSelectDate date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: date)
        
        // Block today and future dates from being selected
        if selected >= today { return }
        
        updateDataForDate(date)
    }
    
    func calendarCell(_ cell: ExerciseCalendarCell, didChangeTo date: Date) {
        selectedDate = date
        selectedDay = nil
        showCenteredMessage = false
        collectionView.reloadData()
    }
    
    func calendarCellDidTapHeader(_ cell: ExerciseCalendarCell) {}
}

extension MedicationCalendarViewController: UICollectionViewDelegate {}
