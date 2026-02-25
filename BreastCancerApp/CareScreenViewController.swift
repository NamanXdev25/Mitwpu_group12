import UIKit

class CareScreenViewController: UIViewController {

    @IBOutlet weak var CareCollectionView: UICollectionView!
    
    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<CareSectionType, CareItem>!
    private var isHydrationExpanded = false
    private var appointmentRefreshTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setupCollectionView()
        configureDataSource()
        applySnapshot()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(medicationDataDidChange),
            name: NSNotification.Name("MedicationDataUpdated"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appointmentDataDidChange),
            name: NSNotification.Name("AppointmentDataUpdated"),
            object: nil
        )
        
        // Refresh symptoms chip whenever a symptom is logged or deleted
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(symptomDataDidChange),
            name: NSNotification.Name("SymptomDataUpdated"),
            object: nil
        )
        
        startAppointmentRefreshTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot(animatingDifferences: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAppointmentRefreshTimer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopAppointmentRefreshTimer()
    }
    
    @objc private func medicationDataDidChange() {
        applySnapshot(animatingDifferences: false)
    }
    
    @objc private func appointmentDataDidChange() {
        applySnapshot(animatingDifferences: false)
    }
    
    @objc private func symptomDataDidChange() {
        applySnapshot(animatingDifferences: true)
    }
    
    // MARK: - Appointment Refresh Timer
    private func startAppointmentRefreshTimer() {
        appointmentRefreshTimer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true
        ) { [weak self] _ in
            self?.checkAndRefreshAppointments()
        }
    }
    
    private func stopAppointmentRefreshTimer() {
        appointmentRefreshTimer?.invalidate()
        appointmentRefreshTimer = nil
    }
    
    private func checkAndRefreshAppointments() {
        applySnapshot(animatingDifferences: true)
    }
    
    // MARK: - Medication Status Helper
    private func medicationStatus() -> String {
        let today = Date()
        MedicationHistory.shared.initializeTodayIfNeeded()
        
        if let history = MedicationHistory.shared.getHistory(for: today) {
            let todaysMeds = history.medications.filter { $0.isScheduledFor(date: today) }
            let taken = todaysMeds.filter { $0.isTaken }.count
            let total = todaysMeds.count
            if total == 0 { return "No medications Added" }
            return "\(taken)/\(total) Taken"
        }
        return "No medications"
    }
    
    // MARK: - Symptom Chips Helper
    /// Returns an array of display strings for the symptom chips.
    /// - Shows up to 3 unique symptom names logged today.
    /// - If more than 3 were logged, appends a "+N" overflow chip.
    /// - Returns an empty array when nothing has been logged today.
    private func todaySymptomChips() -> [String] {
        let todayLogs = SymptomDataSource.shared.getTodayLogs()
        
        // De-duplicate by symptom name, preserving first-occurrence order
        var seen = Set<String>()
        var uniqueNames: [String] = []
        for log in todayLogs {
            if seen.insert(log.symptomName).inserted {
                uniqueNames.append(log.symptomName)
            }
        }
        
        guard !uniqueNames.isEmpty else { return [] }
        
        let maxVisible = 3
        if uniqueNames.count <= maxVisible {
            return uniqueNames
        } else {
            let overflow = uniqueNames.count - maxVisible
            var chips = Array(uniqueNames.prefix(maxVisible))
            chips.append("+\(overflow)")
            return chips
        }
    }
    
    // MARK: - Closest Appointment Helper
    private func closestUpcomingAppointment() -> AppointmentItem? {
        let now = Date()
        let calendar = Calendar.current
        
        let keyFormatter = DateFormatter()
        keyFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let allDateKeys = AppointmentManager.shared.getAllDatesWithAppointments()
        
        var closestAppointment: AppointmentItem? = nil
        var closestDateTime: Date? = nil
        
        for key in allDateKeys {
            guard let date = keyFormatter.date(from: key) else { continue }
            
            let appointments = AppointmentManager.shared.getAppointments(for: date)
            guard !appointments.isEmpty else { continue }
            
            for appointment in appointments {
                guard let timeOnly = timeFormatter.date(from: appointment.time) else { continue }
                
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: timeOnly)
                
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                
                guard let appointmentDateTime = calendar.date(from: dateComponents) else { continue }
                guard appointmentDateTime > now else { continue }
                
                if closestDateTime == nil || appointmentDateTime < closestDateTime! {
                    closestDateTime = appointmentDateTime
                    closestAppointment = appointment
                }
            }
        }
        
        return closestAppointment
    }
    
    // MARK: - Register Cells
    private func registerCells() {
        let cellIdentifiers = [
            "CareHeaderCell",
            "CareHydrationCell",
            "CareMedicationCell",
            "CareDailyExerciseCell",
            "CareSymptomsCell",
            "CareSymptomEmptyCell",   // ← registered here; used inside CareSymptomsCell
            "CareAppointmentsCell",
            "CareViewInsightsCell"
        ]
        
        for identifier in cellIdentifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            CareCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        CareCollectionView.collectionViewLayout = createCompositionalLayout()
        CareCollectionView.delegate = self
        CareCollectionView.backgroundColor = UIColor(named: "logsbgcolor") ?? .systemBackground
        CareCollectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    // MARK: - Create Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let sectionType = CareSectionType(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .todayHeader:       return self.createHeaderSection()
            case .hydration:         return self.createHydrationSection()
            case .medication:        return self.createMedicationSection()
            case .exercise:          return self.createExerciseSection()
            case .symptoms:          return self.createSymptomsSection()
            case .appointmentHeader: return self.createHeaderSection()
            case .appointments:      return self.createAppointmentsSection()
            case .healthInsights:    return self.createHealthInsightsSection()
            }
        }
    }
    
    // MARK: - Section Layouts
    private func createHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(55)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(55)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        return section
    }
    
    private func createHydrationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(209)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(209)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        return section
    }
    
    private func createMedicationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
        return section
    }
    
    private func createExerciseSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(84)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
        return section
    }
    
    private func createSymptomsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }
    
    private func createAppointmentsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(109)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(109)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 22, trailing: 16)
        section.interGroupSpacing = 12
        return section
    }
    
    private func createHealthInsightsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(56)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(56)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16)
        return section
    }
    
    // MARK: - Configure Data Source
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<CareSectionType, CareItem>(
            collectionView: CareCollectionView
        ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            switch item.type {
            case .header(let title, let showManage):
                return self.configureHeaderCell(collectionView, indexPath: indexPath, title: title, showManage: showManage)
            case .hydration:
                return self.configureHydrationCell(collectionView, indexPath: indexPath)
            case .medication(let title, let status, let imageName):
                return self.configureMedicationCell(collectionView, indexPath: indexPath, title: title, status: status, imageName: imageName)
            case .exercise(let title, let duration, let imageName):
                return self.configureExerciseCell(collectionView, indexPath: indexPath, title: title, duration: duration, imageName: imageName)
            case .symptoms(let title, let loggedSymptoms):
                return self.configureSymptomsCell(collectionView, indexPath: indexPath, title: title, symptoms: loggedSymptoms)
            case .appointment(let month, let day, let title, let doctor, let time):
                return self.configureAppointmentCell(collectionView, indexPath: indexPath, month: month, day: day, title: title, doctor: doctor, time: time)
            case .healthInsights:
                return self.configureHealthInsightsCell(collectionView, indexPath: indexPath)
            }
        }
    }
    
    // MARK: - Cell Configuration Methods
    private func configureHeaderCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, showManage: Bool) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareHeaderCell",
            for: indexPath
        ) as! CareHeaderCell
        cell.configure(title: title, showManage: showManage)
        cell.delegate = self
        return cell
    }
    
    private func configureHydrationCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareHydrationCell",
            for: indexPath
        ) as! CareHydrationCell
        cell.configure(
            isExpanded: isHydrationExpanded,
            progress: 0.66,
            currentAmount: "2/3 Ltr",
            goal: "3.0 L",
            cupSize: "200 mL"
        )
        return cell
    }
    
    private func configureMedicationCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, status: String, imageName: String?) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareMedicationCell",
            for: indexPath
        ) as! CareMedicationCell
        let image = imageName != nil ? UIImage(named: imageName!) : UIImage(systemName: "pills.fill")
        cell.configure(title: title, status: medicationStatus(), image: image)
        cell.delegate = self
        return cell
    }
    
    private func configureExerciseCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, duration: String, imageName: String?) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareDailyExerciseCell",
            for: indexPath
        ) as! CareDailyExerciseCell
        let image = imageName != nil ? UIImage(named: imageName!) : UIImage(systemName: "figure.mixed.cardio")
        cell.configure(title: title, duration: duration, image: image)
        cell.delegate = self
        return cell
    }
    
    private func configureSymptomsCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, symptoms: [String]) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareSymptomsCell",
            for: indexPath
        ) as! CareSymptomsCell
        cell.configure(title: title, loggedSymptoms: symptoms)
        cell.delegate = self
        return cell
    }
    
    private func configureAppointmentCell(_ collectionView: UICollectionView, indexPath: IndexPath, month: String, day: String, title: String, doctor: String, time: String) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareAppointmentsCell",
            for: indexPath
        ) as! CareAppointmentsCell
        cell.configure(
            month: month,
            day: day,
            title: title,
            doctor: doctor,
            time: time
        )
        return cell
    }
    
    private func configureHealthInsightsCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CareViewInsightsCell",
            for: indexPath
        ) as! CareViewInsightsCell
        cell.delegate = self
        return cell
    }
    
    // MARK: - Apply Snapshot
    private func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<CareSectionType, CareItem>()
        snapshot.appendSections(CareSectionType.allCases)
        
        // Today Header
        snapshot.appendItems([
            CareItem(id: UUID(), type: .header(title: "Today", showManage: false))
        ], toSection: .todayHeader)
        
        // Hydration
        snapshot.appendItems([
            CareItem(id: UUID(), type: .hydration)
        ], toSection: .hydration)
        
        // Medication
        snapshot.appendItems([
            CareItem(id: UUID(), type: .medication(
                title: "Medication",
                status: medicationStatus(),
                imageName: nil
            ))
        ], toSection: .medication)
        
        // Exercise
        snapshot.appendItems([
            CareItem(id: UUID(), type: .exercise(
                title: "Daily Exercises",
                duration: "15 min",
                imageName: nil
            ))
        ], toSection: .exercise)
        
        // Symptoms — pull live data from SymptomDataSource
        let chips = todaySymptomChips()   // [] when nothing logged today
        snapshot.appendItems([
            CareItem(id: UUID(), type: .symptoms(
                title: "Symptoms logged",
                loggedSymptoms: chips
            ))
        ], toSection: .symptoms)
        
        // Appointments Header
        snapshot.appendItems([
            CareItem(id: UUID(), type: .header(title: "Appointments", showManage: true))
        ], toSection: .appointmentHeader)
        
        // Closest upcoming appointment
        if let closest = closestUpcomingAppointment() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            var month = ""
            var day = ""
            
            if let date = dateFormatter.date(from: closest.date) {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMM"
                month = monthFormatter.string(from: date).uppercased()
                
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "d"
                day = dayFormatter.string(from: date)
            }
            
            snapshot.appendItems([
                CareItem(id: UUID(), type: .appointment(
                    month: month,
                    day: day,
                    title: closest.title.isEmpty ? closest.category : closest.title,
                    doctor: closest.note.isEmpty ? "No notes" : closest.note,
                    time: closest.time
                ))
            ], toSection: .appointments)
            
        } else {
            snapshot.appendItems([
                CareItem(id: UUID(), type: .appointment(
                    month: "---",
                    day: "--",
                    title: "",
                    doctor: "",
                    time: ""
                ))
            ], toSection: .appointments)
        }
        
        // Health Insights
        snapshot.appendItems([
            CareItem(id: UUID(), type: .healthInsights)
        ], toSection: .healthInsights)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UICollectionViewDelegate
extension CareScreenViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item.type {
        case .hydration:
            isHydrationExpanded.toggle()
            applySnapshot(animatingDifferences: true)
        case .medication(let title, _, _):
            print("👆 Selected medication: \(title)")
        case .exercise(let title, _, _):
            print("👆 Selected exercise: \(title)")
        case .symptoms:
            print("👆 View all symptoms tapped")
        case .appointment(_, _, let title, _, _):
            print("👆 Selected appointment: \(title)")
        case .healthInsights:
            print("👆 View health insights tapped")
        default:
            break
        }
    }
}

// MARK: - CareMedicationCellDelegate
extension CareScreenViewController: CareMedicationCellDelegate {
    func careMedicationCellDidTap(_ cell: CareMedicationCell) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        if let medicationVC = storyboard.instantiateViewController(withIdentifier: "MedicationViewController") as? MedicationViewController {
            let navController = UINavigationController(rootViewController: medicationVC)
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(navController, animated: true)
        }
    }
}

// MARK: - CareSymptomsCellDelegate
extension CareScreenViewController: CareSymptomsCellDelegate {
    func careSymptomsCellDidTapViewInsights(_ cell: CareSymptomsCell) {
        let storyboard = UIStoryboard(name: "symptomMain", bundle: nil)
        if let symptomsVC = storyboard.instantiateViewController(withIdentifier: "SymptomsViewController") as? SymptomsViewController {
            let navController = UINavigationController(rootViewController: symptomsVC)
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(navController, animated: true)
        }
    }
}

// MARK: - CareHeaderCellDelegate
extension CareScreenViewController: CareHeaderCellDelegate {
    func careHeaderCellDidTapManage(_ cell: CareHeaderCell) {
        let storyboard = UIStoryboard(name: "Appointments", bundle: nil)
        if let appointmentsVC = storyboard.instantiateViewController(withIdentifier: "AppointmentsViewController") as? AppointmentsViewController {
            let navController = UINavigationController(rootViewController: appointmentsVC)
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(navController, animated: true)
        }
    }
}

// MARK: - CareViewInsightsCellDelegate
extension CareScreenViewController: CareViewInsightsCellDelegate {
    func careViewInsightsCellDidTap(_ cell: CareViewInsightsCell) {
        let storyboard = UIStoryboard(name: "Insights", bundle: nil)
        if let insightsVC = storyboard.instantiateViewController(withIdentifier: "HealthInsightsViewController") as? HealthInsightsViewController {
            navigationController?.pushViewController(insightsVC, animated: true)
        }
    }
}

// MARK: - CareDailyExerciseCellDelegate
extension CareScreenViewController: CareDailyExerciseCellDelegate {
    func careDailyExerciseCellDidTap(_ cell: CareDailyExerciseCell) {
        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        if let exerciseVC = storyboard.instantiateViewController(withIdentifier: "ExercisePlanCategoryViewController") as? ExercisePlanCategoryViewController {
            navigationController?.pushViewController(exerciseVC, animated: true)
        }
    }
}
