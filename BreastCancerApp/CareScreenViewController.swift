import UIKit

class CareScreenViewController: UIViewController {

    @IBOutlet weak var CareCollectionView: UICollectionView!

    // MARK: - Properties
    private let selectedExerciseCategoryIDKeyPrefix = "care_selected_exercise_category_id_v2"
    private var dataSource: UICollectionViewDiffableDataSource<CareSectionType, CareItem>!
    private var isHydrationExpanded = false
    private var appointmentRefreshTimer: Timer?

    private var hydrationGoalML: Int =
        UserDefaults.standard.integer(forKey: "care_hydration_goal_ml") == 0
        ? 3000
        : UserDefaults.standard.integer(forKey: "care_hydration_goal_ml")

    private var hydrationCupSizeML: Int =
        UserDefaults.standard.integer(forKey: "care_hydration_cup_ml") == 0
        ? 200
        : UserDefaults.standard.integer(forKey: "care_hydration_cup_ml")

    private var hydrationCurrentAmountML: Int =
        UserDefaults.standard.integer(forKey: "care_hydration_current_ml") == 0
        ? HydrationDataManager.shared.getTotalForDate(Date())
        : UserDefaults.standard.integer(forKey: "care_hydration_current_ml")

    private let hydrationGoalOptionsML = [1500, 2000, 2500, 3000, 3500]
    private let hydrationCupOptionsML = [100, 150, 200, 250, 300]

    // Custom dropdown UI
    private var dropdownOverlay: UIControl?
    private var dropdownPanel: UIView?
    private var dropdownTableView: UITableView?
    private var dropdownOptions: [Int] = []
    private var dropdownSelectedValue: Int = 0
    private var dropdownTitleForOption: ((Int) -> String)?
    private var dropdownSelectionHandler: ((Int) -> Void)?

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
        hydrationCurrentAmountML = HydrationDataManager.shared.getTotalForDate(Date())
        saveHydrationState()
        applySnapshot(animatingDifferences: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAppointmentRefreshTimer()
        dismissHydrationDropdown()
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

    // MARK: - Hydration Helpers
    private func saveHydrationState() {
        UserDefaults.standard.set(hydrationGoalML, forKey: "care_hydration_goal_ml")
        UserDefaults.standard.set(hydrationCupSizeML, forKey: "care_hydration_cup_ml")
        UserDefaults.standard.set(hydrationCurrentAmountML, forKey: "care_hydration_current_ml")
    }

    private func goalTitle(_ ml: Int) -> String {
        String(format: "%.1f L", Double(ml) / 1000.0)
    }

    private func cupTitle(_ ml: Int) -> String {
        "\(ml) mL"
    }

    private func addDropdownPointer(to panel: UIView, pointerCenterXInPanel: CGFloat) {
        let size = CGSize(width: 14, height: 8)

        let x = max(10, min(pointerCenterXInPanel - size.width / 2, panel.bounds.width - size.width - 10))
        let pointer = UIView(frame: CGRect(x: x, y: -size.height + 2, width: size.width, height: size.height))
        pointer.backgroundColor = .clear
        pointer.layer.zPosition = 1000

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.close()

        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = UIColor.white.withAlphaComponent(0.95).cgColor
        shape.strokeColor = UIColor.white.withAlphaComponent(0.55).cgColor
        shape.lineWidth = 0.5

        pointer.layer.addSublayer(shape)
        panel.addSubview(pointer)
    }


    private func showHydrationDropdown(
        options: [Int],
        selected: Int,
        anchorView: UIView,
        titleForOption: @escaping (Int) -> String,
        onSelect: @escaping (Int) -> Void
    ) {
        dismissHydrationDropdown()

        dropdownOptions = options
        dropdownSelectedValue = selected
        dropdownTitleForOption = titleForOption
        dropdownSelectionHandler = onSelect

        let overlay = UIControl(frame: view.bounds)
        overlay.backgroundColor = .clear
        overlay.addTarget(self, action: #selector(dismissHydrationDropdown), for: .touchUpInside)

        let panelWidth: CGFloat = 220
        let rowHeight: CGFloat = 50
        let panelHeight = CGFloat(options.count) * rowHeight + 6

        let anchorRect = anchorView.convert(anchorView.bounds, to: view)
        var x = anchorRect.midX - panelWidth / 2
        x = max(16, min(x, view.bounds.width - panelWidth - 16))

        var y = anchorRect.maxY + 8
        if y + panelHeight > view.bounds.height - 20 {
            y = anchorRect.minY - panelHeight - 8
        }
        y = max(20, y)

        let panel = UIView(frame: CGRect(x: x, y: y, width: panelWidth, height: panelHeight))
        panel.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        panel.layer.cornerRadius = 20
        panel.layer.masksToBounds = false
        panel.clipsToBounds = false
        panel.layer.borderWidth = 1
        panel.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        panel.layer.shadowColor = UIColor.black.cgColor
        panel.layer.shadowOpacity = 0.10
        panel.layer.shadowRadius = 14
        panel.layer.shadowOffset = CGSize(width: 0, height: 6)

        let pointerCenterXInPanel = anchorRect.midX - panel.frame.minX
        addDropdownPointer(to: panel, pointerCenterXInPanel: pointerCenterXInPanel)

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        blur.frame = panel.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.layer.cornerRadius = 20
        blur.clipsToBounds = true
        panel.addSubview(blur)

        let table = UITableView(frame: panel.bounds.insetBy(dx: 0, dy: 2), style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.dataSource = self
        table.delegate = self
        table.rowHeight = rowHeight
        table.register(UITableViewCell.self, forCellReuseIdentifier: "HydrationDropdownCell")
        table.layer.cornerRadius = 20
        table.clipsToBounds = true

        panel.addSubview(table)
        overlay.addSubview(panel)
        view.addSubview(overlay)

        dropdownOverlay = overlay
        dropdownPanel = panel
        dropdownTableView = table
    }

    @objc
    private func dismissHydrationDropdown() {
        dropdownTableView = nil
        dropdownPanel?.removeFromSuperview()
        dropdownOverlay?.removeFromSuperview()
        dropdownPanel = nil
        dropdownOverlay = nil
        dropdownOptions = []
        dropdownTitleForOption = nil
        dropdownSelectionHandler = nil
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
    private func todaySymptomChips() -> [String] {
        let todayLogs = SymptomDataSource.shared.getTodayLogs()

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
            "CareSymptomEmptyCell",
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
        UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let sectionType = CareSectionType(rawValue: sectionIndex) else { return nil }

            switch sectionType {
            case .todayHeader:       return self.createHeaderSection()
            case .hydration:         return self.createHydrationSection()
            case .medication:        return self.createMedicationSection()
            case .exerciseHeader:    return self.createHeaderSection()
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        return section
    }

    private func createHydrationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(209))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(209))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        return section
    }

    private func createMedicationSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(84))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(84))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }

    private func createExerciseSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(109))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(109))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 22, trailing: 16)
        return section
    }

    private func createSymptomsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }

    private func createAppointmentsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(109))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(109))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 22, trailing: 16)
        section.interGroupSpacing = 12
        return section
    }

    private func createHealthInsightsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(56))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16)
        return section
    }

    // MARK: - Configure Data Source
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<CareSectionType, CareItem>(
            collectionView: CareCollectionView
        ) { [weak self] collectionView, indexPath, item in
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareHeaderCell", for: indexPath) as! CareHeaderCell
        let actionTitle: String
        if title == "Exercises" {
            actionTitle = selectedExerciseCategory() == nil ? "Add Plan" : "Change Plan"
        } else {
            actionTitle = "Manage"
        }
        cell.configure(title: title, showManage: showManage, actionTitle: actionTitle)
        cell.delegate = self
        return cell
    }

    private func configureHydrationCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareHydrationCell", for: indexPath) as! CareHydrationCell
        cell.delegate = self
        cell.configure(
            isExpanded: isHydrationExpanded,
            currentAmountML: hydrationCurrentAmountML,
            goalML: hydrationGoalML,
            cupSizeML: hydrationCupSizeML
        )
        return cell
    }

    private func configureMedicationCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, status: String, imageName: String?) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareMedicationCell", for: indexPath) as! CareMedicationCell
        let image = imageName != nil ? UIImage(named: imageName!) : UIImage(systemName: "pills.fill")
        cell.configure(title: title, status: medicationStatus(), image: image)
        cell.delegate = self
        return cell
    }

    private func configureExerciseCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, duration _: String, imageName: String?) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareDailyExerciseCell", for: indexPath) as! CareDailyExerciseCell
        if let category = selectedExerciseCategory() {
            let displayTitle = category.title
            let image = UIImage(named: category.headerImageName ?? "") ?? UIImage(systemName: "figure.mixed.cardio")
            cell.configure(
                title: displayTitle,
                image: image,
                hasPlan: true
            )
        } else {
            let image = imageName != nil ? UIImage(named: imageName!) : UIImage(systemName: "figure.mixed.cardio")
            cell.configure(
                title: title,
                image: image,
                hasPlan: false
            )
        }
        cell.delegate = self
        return cell
    }

    private func configureSymptomsCell(_ collectionView: UICollectionView, indexPath: IndexPath, title: String, symptoms: [String]) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareSymptomsCell", for: indexPath) as! CareSymptomsCell
        cell.configure(title: title, loggedSymptoms: symptoms)
        cell.delegate = self
        return cell
    }

    private func configureAppointmentCell(_ collectionView: UICollectionView, indexPath: IndexPath, month: String, day: String, title: String, doctor: String, time: String) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareAppointmentsCell", for: indexPath) as! CareAppointmentsCell
        cell.configure(month: month, day: day, title: title, doctor: doctor, time: time)
        return cell
    }

    private func configureHealthInsightsCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareViewInsightsCell", for: indexPath) as! CareViewInsightsCell
        cell.delegate = self
        return cell
    }

    // MARK: - Apply Snapshot
    private func applySnapshot(animatingDifferences: Bool = false) {
        dismissHydrationDropdown()

        var snapshot = NSDiffableDataSourceSnapshot<CareSectionType, CareItem>()
        snapshot.appendSections(CareSectionType.allCases)

        snapshot.appendItems([CareItem(id: UUID(), type: .header(title: "Today", showManage: false))], toSection: .todayHeader)
        snapshot.appendItems([CareItem(id: UUID(), type: .hydration)], toSection: .hydration)

        snapshot.appendItems([
            CareItem(id: UUID(), type: .medication(
                title: "Medication",
                status: medicationStatus(),
                imageName: nil
            ))
        ], toSection: .medication)

        snapshot.appendItems([CareItem(id: UUID(), type: .header(title: "Exercises", showManage: true))], toSection: .exerciseHeader)

        snapshot.appendItems([
            CareItem(id: UUID(), type: .exercise(
                title: "Daily Exercises",
                duration: "15 min",
                imageName: nil
            ))
        ], toSection: .exercise)

        let chips = todaySymptomChips()
        snapshot.appendItems([
            CareItem(id: UUID(), type: .symptoms(
                title: "Symptoms logged",
                loggedSymptoms: chips
            ))
        ], toSection: .symptoms)

        snapshot.appendItems([CareItem(id: UUID(), type: .header(title: "Appointments", showManage: true))], toSection: .appointmentHeader)

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
                    title: closest.title,
                    doctor: closest.doctor.isEmpty ? closest.location : closest.doctor,
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

        snapshot.appendItems([CareItem(id: UUID(), type: .healthInsights)], toSection: .healthInsights)
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
        case .appointment(_, _, _, _, _):
            guard let appointment = closestUpcomingAppointment() else { return }
            let storyboard = UIStoryboard(name: "Appointments", bundle: nil)
            guard let navController = storyboard.instantiateViewController(withIdentifier: "NewAppointmentNavController") as? UINavigationController,
                  let viewVC = navController.topViewController as? NewAppointmentViewController
            else { return }
            viewVC.initialAppointment = appointment
            viewVC.isViewMode = true
            viewVC.delegate = self
            navController.modalPresentationStyle = .pageSheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            present(navController, animated: true)
        case .healthInsights:
            print("👆 View health insights tapped")
        default:
            break
        }
    }
}

// MARK: - Exercise Plan State
extension CareScreenViewController {
    private var selectedExerciseCategoryIDKey: String {
        let userKey = SupabaseUserContext.currentUserId?.uuidString ?? "anonymous"
        return "\(selectedExerciseCategoryIDKeyPrefix)_\(userKey)"
    }

    private func selectedExerciseCategory() -> ExercisePlanCategory? {
        guard let rawValue = UserDefaults.standard.object(forKey: selectedExerciseCategoryIDKey) as? Int else {
            return nil
        }
        let id = rawValue
        guard id > 0 else { return nil }
        return ExercisePlanCategory.allCategories.first(where: { $0.id == id })
    }

    private func saveSelectedExerciseCategory(_ category: ExercisePlanCategory) {
        UserDefaults.standard.set(category.id, forKey: selectedExerciseCategoryIDKey)
    }

    private func durationText(from subtitle: String) -> String {
        let components = subtitle.components(separatedBy: "·")
        if components.count >= 2 {
            return components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "15 min"
    }

    private func openExercisePlanPicker() {
        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        guard let pickerVC = storyboard.instantiateViewController(withIdentifier: "ExercisePlanCategoryViewController") as? ExercisePlanCategoryViewController else {
            return
        }

        pickerVC.onCategorySelected = { [weak self] category in
            guard let self = self else { return }
            self.saveSelectedExerciseCategory(category)
            self.applySnapshot(animatingDifferences: false)
        }
        navigationController?.pushViewController(pickerVC, animated: true)
    }

    private func openSelectedExercisePlanIfAvailable() {
        guard let category = selectedExerciseCategory() else {
            openExercisePlanPicker()
            return
        }

        let plan = NewExercisePlan(
            level: category.title,
            duration: durationText(from: category.subtitle),
            exerciseCount: category.exercises.count,
            note: "Important: \(category.importantNote)",
            exercises: category.exercises.map { exercise in
                NewExerciseModel(
                    imageName: exercise.imageName,
                    title: exercise.name,
                    category: "Exercise",
                    difficulty: "Medium",
                    duration: exercise.details,
                    youtubeURL: exercise.youtubeURL
                )
            }
        )

        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "NewExerciseViewController") as? NewExerciseViewController else {
            return
        }
        detailVC.exercisePlan = plan
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CareHydrationCellDelegate
extension CareScreenViewController: CareHydrationCellDelegate {

    func careHydrationCellDidTapGoal(_ cell: CareHydrationCell) {
        showHydrationDropdown(
            options: hydrationGoalOptionsML,
            selected: hydrationGoalML,
            anchorView: cell.GoalChevronButton,
            titleForOption: { [weak self] in self?.goalTitle($0) ?? "" }
        ) { [weak self] selectedGoal in
            guard let self = self else { return }
            self.hydrationGoalML = selectedGoal
            self.hydrationCurrentAmountML = min(self.hydrationCurrentAmountML, selectedGoal)
            HydrationDataManager.shared.setTotalForToday(self.hydrationCurrentAmountML)
            self.hydrationCurrentAmountML = HydrationDataManager.shared.getTotalForDate(Date())
            self.saveHydrationState()
            self.applySnapshot(animatingDifferences: false)
        }
    }

    func careHydrationCellDidTapCupSize(_ cell: CareHydrationCell) {
        showHydrationDropdown(
            options: hydrationCupOptionsML,
            selected: hydrationCupSizeML,
            anchorView: cell.CupSizeChevronButton,
            titleForOption: { [weak self] in self?.cupTitle($0) ?? "" }
        ) { [weak self] selectedCup in
            guard let self = self else { return }
            self.hydrationCupSizeML = selectedCup
            self.saveHydrationState()
            self.applySnapshot(animatingDifferences: false)
        }
    }

    func careHydrationCell(_ cell: CareHydrationCell, didChangeCurrentAmountML amountML: Int) {
        let previousAmount = hydrationCurrentAmountML
        hydrationCurrentAmountML = min(max(amountML, 0), hydrationGoalML)
        let delta = hydrationCurrentAmountML - previousAmount
        HydrationDataManager.shared.adjustToday(by: delta)
        hydrationCurrentAmountML = HydrationDataManager.shared.getTotalForDate(Date())
        saveHydrationState()
    }
}

// MARK: - Hydration Dropdown Table
extension CareScreenViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dropdownOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let value = dropdownOptions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HydrationDropdownCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = dropdownTitleForOption?(value) ?? "\(value)"
        content.textProperties.font = .systemFont(ofSize: 16, weight: .regular)
        content.textProperties.color = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0)

        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = dropdownOptions[indexPath.row]
        dropdownSelectionHandler?(value)
        dismissHydrationDropdown()
    }
}

// MARK: - CareMedicationCellDelegate
extension CareScreenViewController: CareMedicationCellDelegate {
    func careMedicationCellDidTap(_ cell: CareMedicationCell) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        if let medicationVC = storyboard.instantiateViewController(withIdentifier: "MedicationViewController") as? MedicationViewController {
            medicationVC.displayDate = Date()
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
            symptomsVC.displayDate = Date()
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
        if let indexPath = CareCollectionView.indexPath(for: cell),
           let sectionType = CareSectionType(rawValue: indexPath.section),
           sectionType == .exerciseHeader {
            openExercisePlanPicker()
            return
        }

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
    func careDailyExerciseCellDidTapBegin(_ cell: CareDailyExerciseCell) {
        openSelectedExercisePlanIfAvailable()
    }
}

// MARK: - AddAppointmentDelegate
extension CareScreenViewController: AddAppointmentDelegate {
    func didAddAppointment(_ appointment: AppointmentItem) {
        let df = DateFormatter(); df.dateFormat = "dd MMM yyyy"
        if let date = df.date(from: appointment.date) {
            AppointmentManager.shared.saveAppointment(appointment, for: date)
        }
        NotificationCenter.default.post(name: NSNotification.Name("AppointmentDataUpdated"), object: nil)
    }
}
