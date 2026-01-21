import UIKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var exercisesCollectionView: UICollectionView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    // Variables
    var selectedDate = Date()
    private var selectedDay: Date?
    private var missedExercises: [PlanItem] = []
    private var completedExercises: [PlanItem] = []
    private var exerciseDays: Set<Date> = []
    private var showCenteredMessage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupExercisesCollectionView()
        loadExerciseDays()
        
        // Initial load
        exercisesCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ExerciseManager.shared.updateHistoryForToday()
        ExerciseManager.shared.updateHistoryForAllDates()
        loadExerciseDays()
        exercisesCollectionView.reloadData()
        
        adjustBottomInset()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustBottomInset()
    }
    
    private func adjustBottomInset() {
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 49
        let extraPadding: CGFloat = 20
        exercisesCollectionView.contentInset.bottom = tabBarHeight + extraPadding
        exercisesCollectionView.verticalScrollIndicatorInsets .bottom = tabBarHeight + extraPadding
    }
    
    private func loadExerciseDays() {
        exerciseDays.removeAll()
        let calendar = Calendar.current
        
        for (dateKey, _) in ExerciseManager.shared.history {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateKey) {
                let normalized = calendar.startOfDay(for: date)
                exerciseDays.insert(normalized)
            }
        }
    }
    
    private func setupExercisesCollectionView() {
        exercisesCollectionView.dataSource = self
        exercisesCollectionView.delegate = self
        
        exercisesCollectionView.register(
            UINib(nibName: "ExerciseCalendarCell", bundle: nil),
            forCellWithReuseIdentifier: "ExerciseCalendarCell"
        )
        
        exercisesCollectionView.register(
            UINib(nibName: "ExerciseItemCell", bundle: nil),
            forCellWithReuseIdentifier: "ExerciseItemCell"
        )
        
        // Register centered message cell
        exercisesCollectionView.register(
            UINib(nibName: "CenteredMessageCell", bundle: nil),
            forCellWithReuseIdentifier: "CenteredMessageCell"
        )
        
        // Register section header
        exercisesCollectionView.register(
            UINib(nibName: "ExerciseSectionHeader", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "ExerciseSectionHeader"
        )
        
        exercisesCollectionView.collectionViewLayout = createLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            if sectionIndex == 0 {
                return self.createCalendarSection()
            } else if self.showCenteredMessage && sectionIndex == 1 {
                return self.createCenteredMessageSection()
            } else {
                let hasItems = sectionIndex == 1 ? !self.missedExercises.isEmpty : !self.completedExercises.isEmpty
                let hasHeader = self.shouldShowHeader(for: sectionIndex)
                return self.createExercisesSection(hasItems: hasItems, hasHeader: hasHeader)
            }
        }
    }
    
    private func shouldShowHeader(for section: Int) -> Bool {
        if showCenteredMessage { return false }
        
        guard let date = selectedDay else { return false }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) || date > Date() { return false }
        
        let key = ExerciseManager.shared.getDateKey(for: date)
        if ExerciseManager.shared.history[key] != nil {
            if section == 1 { return !missedExercises.isEmpty }
            if section == 2 { return !completedExercises.isEmpty }
        }
        return false
    }
    
    private func createCalendarSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(386)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(386)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createCenteredMessageSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createExercisesSection(hasItems: Bool, hasHeader: Bool) -> NSCollectionLayoutSection {
        let height: CGFloat = hasItems ? 35 : 0.01
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(height)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(height)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        
        let bottomInset: CGFloat = hasItems ? 16 : 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: bottomInset, trailing: 16)
        
        let headerHeight: NSCollectionLayoutDimension = hasHeader ? .estimated(44) : .absolute(0.01)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: headerHeight
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        if hasHeader || hasItems {
            section.boundarySupplementaryItems = [header]
        }
        
        return section
    }
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return showCenteredMessage ? 2 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if showCenteredMessage && section == 1 { return 1 }
        if section == 1 { return missedExercises.count }
        return completedExercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCalendarCell", for: indexPath) as! ExerciseCalendarCell
            cell.configure(with: selectedDate, exerciseDays: exerciseDays, selectedDay: selectedDay)
            cell.delegate = self
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell
        }
        
        if showCenteredMessage && indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenteredMessageCell", for: indexPath) as! CenteredMessageCell
            cell.configure(message: "No exercises planned")
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseItemCell", for: indexPath) as! ExerciseItemCell
        let exercise = indexPath.section == 1 ? missedExercises[indexPath.item] : completedExercises[indexPath.item]
        let count = indexPath.section == 1 ? missedExercises.count : completedExercises.count
        
        cell.configure(with: exercise, isFirst: indexPath.item == 0, isLast: indexPath.item == count - 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && !showCenteredMessage && (indexPath.section == 1 || indexPath.section == 2) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExerciseSectionHeader", for: indexPath) as! ExerciseSectionHeader
            
            guard let date = selectedDay else {
                header.configure(status: "")
                return header
            }
            
            let calendar = Calendar.current
            if calendar.isDateInToday(date) || date > Date() {
                header.configure(status: "")
                return header
            }
            
            let key = ExerciseManager.shared.getDateKey(for: date)
            if ExerciseManager.shared.history[key] != nil {
                if indexPath.section == 1 {
                    header.configure(status: missedExercises.isEmpty ? "" : "Missed")
                } else {
                    header.configure(status: completedExercises.isEmpty ? "" : "Done")
                }
            } else {
                header.configure(status: "")
            }
            
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate
extension CalendarViewController: UICollectionViewDelegate {}

// MARK: - ExerciseCalendarCellDelegate
extension CalendarViewController: ExerciseCalendarCellDelegate {
    func calendarCell(_ cell: ExerciseCalendarCell, didSelectDate date: Date) {
        selectedDay = date
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) || date > Date() {
            missedExercises = []
            completedExercises = []
            showCenteredMessage = false
        } else {
            let key = ExerciseManager.shared.getDateKey(for: date)
            if let progress = ExerciseManager.shared.history[key] {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                timeFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                let sortedItems = progress.items.sorted { item1, item2 in
                    if let date1 = timeFormatter.date(from: item1.time),
                       let date2 = timeFormatter.date(from: item2.time) {
                        return date1 < date2
                    }
                    return item1.time < item2.time
                }
                missedExercises = sortedItems.filter { !$0.isCompleted }
                completedExercises = sortedItems.filter { $0.isCompleted }
                showCenteredMessage = false
            } else {
                missedExercises = []
                completedExercises = []
                showCenteredMessage = true
            }
        }
        
        exercisesCollectionView.collectionViewLayout.invalidateLayout()
        exercisesCollectionView.reloadData()
    }
    
    func calendarCell(_ cell: ExerciseCalendarCell, didChangeTo date: Date) {
        selectedDate = date
        missedExercises.removeAll()
        completedExercises.removeAll()
        selectedDay = nil
        showCenteredMessage = false
        exercisesCollectionView.collectionViewLayout.invalidateLayout()
        exercisesCollectionView.reloadData()
    }
    
    func calendarCellDidTapHeader(_ cell: ExerciseCalendarCell) {}
}
