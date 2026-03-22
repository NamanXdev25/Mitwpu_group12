import UIKit

// MARK: - Saved phase state (lives in the VC, survives cell reuse)
struct SavedPhaseState {
    var status: PhaseStatus
    var model: TreatmentPhaseModel?

    var treatmentType: TreatmentType = .none
    var startDate: Date?             = nil
    var duration: String             = ""
    var isSaved: Bool                = false

    // MARK: Conversion to/from PersistedPhaseState
    func toPersistedState() -> PersistedPhaseState {
        PersistedPhaseState(
            treatmentTypeRaw: treatmentType.rawValue,
            startDate:        startDate,
            duration:         duration,
            isSaved:          isSaved,
            statusRaw:        status.rawStringValue
        )
    }

    static func from(_ p: PersistedPhaseState) -> SavedPhaseState {
        let type   = TreatmentType(rawValue: p.treatmentTypeRaw) ?? .none
        let status = PhaseStatus.from(rawStringValue: p.statusRaw)
        var state  = SavedPhaseState(status: status)
        state.treatmentType = type
        state.startDate     = p.startDate
        state.duration      = p.duration
        state.isSaved       = p.isSaved
        if p.isSaved {
            var model = TreatmentPhaseModel()
            model.treatmentType = type
            model.startDate     = p.startDate
            model.duration      = p.duration
            model.state         = .saved
            state.model         = model
        }
        return state
    }
}

// MARK: - Saved post-treatment state (lives in VC, survives cell reuse)
struct SavedPostTreatmentState {
    var selectedDate: Date?           = nil
    var selectedSymptoms: Set<String> = []
    var isSaved: Bool                 = false

    func toPersistedState() -> PersistedPostTreatmentState {
        PersistedPostTreatmentState(
            selectedDate:     selectedDate,
            selectedSymptoms: Array(selectedSymptoms),
            isSaved:          isSaved
        )
    }

    static func from(_ p: PersistedPostTreatmentState) -> SavedPostTreatmentState {
        SavedPostTreatmentState(
            selectedDate:     p.selectedDate,
            selectedSymptoms: Set(p.selectedSymptoms),
            isSaved:          p.isSaved
        )
    }
}

// MARK: - PhaseStatus persistence helpers
extension PhaseStatus {
    var rawStringValue: String {
        switch self {
        case .notStarted: return "notStarted"
        case .inProgress: return "inProgress"
        case .completed:  return "completed"
        }
    }
    static func from(rawStringValue: String) -> PhaseStatus {
        switch rawStringValue {
        case "inProgress": return .inProgress
        case "completed":  return .completed
        default:           return .notStarted
        }
    }
}

class JourneyViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Models
    private var diagnosisModel  = DiagnosisModel()
    private var waitModel       = WaitModel()
    private var treatmentModel  = TreatmentModel()

    private var cellHeights: [Int: CGFloat] = [
        0: 280,
        1: 510,
        2: 150,
        3: 397
    ]

    private var savedPhaseStates: [SavedPhaseState] = []
    private var treatmentBadgeStatus: PhaseStatus = .notStarted

    private var savedPostTreatmentState = SavedPostTreatmentState()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()

        if JourneyState.shared.isDiagnosisCompleted { diagnosisModel.status = "Completed" }
        if JourneyState.shared.isWaitCompleted      { waitModel.status      = "Completed" }
        if JourneyState.shared.isTreatmentCompleted { treatmentModel.status = "Completed" }

        diagnosisModel.diagnosisDate = JourneyState.shared.diagnosisDate
        waitModel.daysWaited = JourneyState.shared.waitDaysInput
        waitModel.selectedFeelings = Set(JourneyState.shared.waitSymptoms)

        savedPhaseStates     = JourneyState.shared.persistedPhaseStates.map { SavedPhaseState.from($0) }
        treatmentBadgeStatus = PhaseStatus.from(rawStringValue: JourneyState.shared.persistedTreatmentBadge)
        savedPostTreatmentState = SavedPostTreatmentState.from(JourneyState.shared.persistedPostTreatment)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Persist state to JourneyState
    private func persistPhaseStates() {
        JourneyState.shared.savePhaseStates(
            savedPhaseStates.map { $0.toPersistedState() },
            badgeStatus: treatmentBadgeStatus.rawStringValue
        )
    }

    private func persistPostTreatmentState() {
        JourneyState.shared.savePostTreatmentState(savedPostTreatmentState.toPersistedState())
    }

    // MARK: - Treatment name sync
    private func syncTreatmentName() {
        let best = savedPhaseStates
            .filter { $0.treatmentType != .none }
            .last
        let name = best.map { $0.treatmentType.rawValue } ?? "Not started yet"
        JourneyState.shared.updateTreatmentPhaseName(name)
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Journey"
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "DiagnosisCell",     bundle: nil), forCellWithReuseIdentifier: "DiagnosisCell")
        collectionView.register(UINib(nibName: "WaitCell",          bundle: nil), forCellWithReuseIdentifier: "WaitCell")
        collectionView.register(UINib(nibName: "TreatmentCell",     bundle: nil), forCellWithReuseIdentifier: "TreatmentCell")
        collectionView.register(UINib(nibName: "PostTreatmentCell", bundle: nil), forCellWithReuseIdentifier: "PostTreatmentCell")

        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize       = .zero
            layout.minimumLineSpacing      = 16
            layout.minimumInteritemSpacing = 0
            layout.sectionInset            = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }

    // MARK: - Height Update
    private func updateHeight(for index: Int, height: CGFloat) {
        guard cellHeights[index] != height else { return }
        cellHeights[index] = height
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates(nil)
        }
    }

    // MARK: - Sequential unlock helpers
    private func isUnlocked(_ index: Int) -> Bool {
        switch index {
        case 0: return true
        case 1: return JourneyState.shared.isDiagnosisCompleted
        case 2: return JourneyState.shared.isWaitCompleted
        case 3: return JourneyState.shared.isTreatmentCompleted
        default: return false
        }
    }

    private func reloadAllCells() {
        UIView.performWithoutAnimation { collectionView.reloadData() }
    }

    // MARK: - TreatmentCell wiring
    private func configureTreatmentCell(_ cell: TreatmentCell, for indexPath: IndexPath) {
        cell.restoreState(phases: savedPhaseStates, badgeStatus: treatmentBadgeStatus)
        cellHeights[2] = cell.getCellHeight()
        cell.setLocked(!isUnlocked(2))

        cell.onSaveButtonTapped = { [weak self] phase, index in
            guard let self else { return }
            self.treatmentModel.phases.append(phase)
            if index < self.savedPhaseStates.count {
                self.savedPhaseStates[index].model         = phase
                self.savedPhaseStates[index].isSaved       = true
                self.savedPhaseStates[index].treatmentType = phase.treatmentType
                self.savedPhaseStates[index].startDate     = phase.startDate
                self.savedPhaseStates[index].duration      = phase.duration
            }
            self.syncTreatmentName()
            self.persistPhaseStates()
        }

        cell.onPhaseStatusChanged = { [weak self] index, status in
            guard let self, index < self.savedPhaseStates.count else { return }
            self.savedPhaseStates[index].status = status
            self.persistPhaseStates()
        }

        cell.onPhaseFieldsChanged = { [weak self] index, type, startDate, duration in
            guard let self, index < self.savedPhaseStates.count else { return }
            self.savedPhaseStates[index].treatmentType = type
            self.savedPhaseStates[index].startDate     = startDate
            self.savedPhaseStates[index].duration      = duration
            self.savedPhaseStates[index].isSaved       = false
            self.syncTreatmentName()
            self.persistPhaseStates()
        }

        cell.onPhaseAdded = { [weak self] in
            guard let self else { return }
            self.savedPhaseStates.append(SavedPhaseState(status: .notStarted, model: nil))
            self.persistPhaseStates()
        }

        cell.onPhaseDeleted = { [weak self] index in
            guard let self, index < self.savedPhaseStates.count else { return }
            self.savedPhaseStates.remove(at: index)
            self.syncTreatmentName()
            self.persistPhaseStates()
            
            if self.savedPhaseStates.isEmpty {
                self.savedPostTreatmentState = SavedPostTreatmentState()
                JourneyState.shared.resetTreatment()
            }
        }

        cell.onAllPhasesCompleted = { [weak self] phaseName in
            guard let self else { return }
            self.treatmentBadgeStatus = .completed
            JourneyState.shared.completeTreatment(phaseName: phaseName)
            self.persistPhaseStates()
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [IndexPath(item: 3, section: 0)])
            }
        }

        cell.onTreatmentReset = { [weak self] in
            guard let self else { return }
            self.treatmentBadgeStatus = .notStarted
            JourneyState.shared.resetTreatment()
            self.persistPhaseStates()
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [IndexPath(item: 3, section: 0)])
            }
        }

        cell.onCellHeightChanged = { [weak self] in
            guard let self else { return }
            self.updateHeight(for: 2, height: cell.getCellHeight())
        }
    }

    // MARK: - PostTreatmentCell wiring
    private func configurePostTreatmentCell(_ cell: PostTreatmentCell) {
        cell.restoreState(savedPostTreatmentState)
        cellHeights[3] = cell.getCellHeight()
        cell.setLocked(!isUnlocked(3))

        cell.onDateChanged = { [weak self] date in
            self?.savedPostTreatmentState.selectedDate = date
            self?.persistPostTreatmentState()
        }

        cell.onDateTapped = { [weak self] in
            self?.presentPostTreatmentCalendar()
        }

        cell.onSymptomsChanged = { [weak self] symptoms in
            self?.savedPostTreatmentState.selectedSymptoms = symptoms
            self?.persistPostTreatmentState()
        }

        cell.onSaveButtonTapped = { [weak self] in
            guard let self else { return }
            self.savedPostTreatmentState.isSaved = true
            self.persistPostTreatmentState()
            JourneyState.shared.completePostTreatment()
        }

        cell.onEditButtonTapped = { [weak self] in
            self?.savedPostTreatmentState.isSaved = false
            self?.persistPostTreatmentState()
        }

        cell.onCellHeightChanged = { [weak self] in
            guard let self else { return }
            self.updateHeight(for: 3, height: cell.getCellHeight())
        }
    }
}

// MARK: - UICollectionViewDataSource

extension JourneyViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { 4 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.item {

        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DiagnosisCell", for: indexPath) as? DiagnosisCell
            else { return UICollectionViewCell() }

            cell.configure(with: diagnosisModel)
            cell.setLocked(false)

            cell.onDateSelected = { [weak self] date in
                self?.diagnosisModel.diagnosisDate = date
            }

            cell.onSaveButtonTapped = { [weak self] in
                guard let self else { return }
                self.diagnosisModel.status = "Completed"
                JourneyState.shared.saveDiagnosisState(date: self.diagnosisModel.diagnosisDate)
                JourneyState.shared.completeDiagnosis()
                UIView.performWithoutAnimation {
                    self.collectionView.reloadItems(at: [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0)
                    ])
                }
            }

            cell.onEditButtonTapped = { [weak self] in
                guard let self else { return }
                self.diagnosisModel.status = "Not Started"
                JourneyState.shared.resetDiagnosis()
                self.savedPhaseStates        = []
                self.treatmentBadgeStatus    = .notStarted
                self.savedPostTreatmentState = SavedPostTreatmentState()
                UIView.performWithoutAnimation {
                    self.collectionView.reloadItems(at: [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0)
                    ])
                }
            }

            return cell

        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "WaitCell", for: indexPath) as? WaitCell
            else { return UICollectionViewCell() }

            cell.onSaveButtonTapped = { [weak self] days, symptoms in
                guard let self else { return }
                self.waitModel.status = "Completed"
                self.waitModel.daysWaited = days
                self.waitModel.selectedFeelings = Set(symptoms)
                JourneyState.shared.saveWaitState(days: days, symptoms: symptoms)
                UIView.performWithoutAnimation {
                    self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
                }
            }

            cell.onWaitPeriodExpired = { [weak self] in
                guard let self else { return }
                JourneyState.shared.completeWait()
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.collectionView.reloadItems(at: [IndexPath(item: 2, section: 0)])
                    }
                }
            }

            cell.onEditButtonTapped = { [weak self] in
                guard let self else { return }
                self.waitModel.status = "Not Started"
                JourneyState.shared.resetWait()
                self.savedPhaseStates        = []
                self.treatmentBadgeStatus    = .notStarted
                self.savedPostTreatmentState = SavedPostTreatmentState()
                UIView.performWithoutAnimation {
                    self.collectionView.reloadItems(at: [
                        IndexPath(item: 1, section: 0),
                        IndexPath(item: 2, section: 0),
                        IndexPath(item: 3, section: 0)
                    ])
                }
            }

            cell.onCellHeightChanged = { [weak self] in
                guard let self else { return }
                self.updateHeight(for: 1, height: cell.getCellHeight())
            }

            cell.configure(with: waitModel)
            cell.setLocked(!isUnlocked(1))

            return cell

        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TreatmentCell", for: indexPath) as? TreatmentCell
            else { return UICollectionViewCell() }

            configureTreatmentCell(cell, for: indexPath)
            return cell

        default:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PostTreatmentCell", for: indexPath) as? PostTreatmentCell
            else { return UICollectionViewCell() }

            configurePostTreatmentCell(cell)
            return cell
        }
    }
}

// MARK: - PostTreatment Calendar Popup

extension JourneyViewController {

    private func presentPostTreatmentCalendar() {
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimView.tag = 999
        dimView.alpha = 0
        view.addSubview(dimView)

        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        dimView.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 340),
            container.heightAnchor.constraint(equalToConstant: 460)
        ])

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        if let existing = savedPostTreatmentState.selectedDate {
            datePicker.date = existing
        }
        container.addSubview(datePicker)

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(buttonStack)

        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.systemRed, for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 16)

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 16)

        buttonStack.addArrangedSubview(resetButton)
        buttonStack.addArrangedSubview(doneButton)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            buttonStack.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])

        UIView.animate(withDuration: 0.25) { dimView.alpha = 1 }

        datePicker.addTarget(self, action: #selector(postTreatmentDateChanged(_:)), for: .valueChanged)

        doneButton.addAction(UIAction { [weak self] _ in
            self?.dismissCalendarPopup(clearDate: false)
        }, for: .touchUpInside)

        resetButton.addAction(UIAction { [weak self] _ in
            self?.savedPostTreatmentState.selectedDate = nil
            self?.persistPostTreatmentState()
            self?.dismissCalendarPopup(clearDate: true)
        }, for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(calendarBackgroundTapped))
        tap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(tap)
    }

    @objc private func postTreatmentDateChanged(_ picker: UIDatePicker) {
        savedPostTreatmentState.selectedDate = picker.date
        persistPostTreatmentState()
    }

    @objc private func calendarBackgroundTapped() {
        dismissCalendarPopup(clearDate: false)
    }

    private func dismissCalendarPopup(clearDate: Bool) {
        guard let dimView = view.viewWithTag(999) else { return }
        UIView.animate(withDuration: 0.25, animations: { dimView.alpha = 0 }) { _ in
            dimView.removeFromSuperview()
        }
        let indexPath = IndexPath(item: 3, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? PostTreatmentCell else { return }
        if clearDate {
            cell.clearSelectedDate()
        } else if let date = savedPostTreatmentState.selectedDate {
            cell.updateSelectedDate(date)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension JourneyViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = view.bounds.width
        let padding: CGFloat = 32
        let cellWidth = totalWidth - padding
        let height = cellHeights[indexPath.item] ?? 200
        return CGSize(width: cellWidth, height: height)
    }
}
