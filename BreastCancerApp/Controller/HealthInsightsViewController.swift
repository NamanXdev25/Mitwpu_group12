import UIKit

class HealthInsightsViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    // MARK: - Outlets

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var filterBarButton: UIBarButtonItem?

    // MARK: - State

    var healthInsights: [HealthInsight] = []
    private let insightBuilder = HealthInsightBuilder()
    private let calendar = Calendar.current

    private var selectedMedicationDate = Calendar.current.startOfDay(for: Date())
    private var selectedSymptomDate = Calendar.current.startOfDay(for: Date())
    private var shouldHighlightMedicationSelection = false
    private var shouldHighlightSymptomSelection = false

    private var activeFilter: InsightDateFilter = .currentWeek {
        didSet { refreshFilterAppearance() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "BackgroundColor")
        collectionView.backgroundColor = .clear
        super.viewDidLoad()
        setupCollectionView()
        setupObservers()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - IBAction (connected in Insights.storyboard)

    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        guard activeFilter.isCustom else {
            presentDatePicker()
            return
        }
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Change Date…", style: .default) { [weak self] _ in
            self?.presentDatePicker()
        })
        sheet.addAction(UIAlertAction(title: "Show Current Week", style: .default) { [weak self] _ in
            self?.clearFilter()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let pop = sheet.popoverPresentationController { pop.barButtonItem = sender }
        present(sheet, animated: true)
    }

    // MARK: - Nav bar appearance

    /// ONLY updates the title — never touches the button image or tint.
    /// The storyboard owns the button design completely.
    private func refreshFilterAppearance() {
        navigationItem.title = activeFilter.displayTitle
    }

    // MARK: - Date picker presentation

    private func presentDatePicker() {
        let storyboard = UIStoryboard(name: "Insights", bundle: nil)
        guard let navController = storyboard.instantiateViewController(
            withIdentifier: "InsightDatePickerNavigationController"
        ) as? UINavigationController else {
            assertionFailure("InsightDatePickerNavigationController not found in Insights.storyboard")
            return
        }
        guard let pickerVC = navController.viewControllers.first
            as? InsightDatePickerViewController
        else {
            assertionFailure("Root VC is not InsightDatePickerViewController")
            return
        }
        if case let .week(anchor) = activeFilter {
            pickerVC.initialDate = anchor
        }
        pickerVC.onApply = { [weak self] pickedDate in
            self?.applyFilter(for: pickedDate)
        }
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 24
        }
        present(navController, animated: true)
    }

    // MARK: - Filter state

    private func applyFilter(for date: Date) {
        selectedMedicationDate = calendar.startOfDay(for: Date())
        selectedSymptomDate = calendar.startOfDay(for: Date())
        shouldHighlightMedicationSelection = false
        shouldHighlightSymptomSelection = false
        activeFilter = .week(containing: date)
        loadData()
    }

    private func clearFilter() {
        activeFilter = .currentWeek
        loadData()
    }

    // MARK: - Data

    private func loadData() {
        normalizeSelectedDates()
        healthInsights = insightBuilder.buildInsights(filter: activeFilter)
        collectionView.reloadData()
    }

    @objc private func handleCareDataUpdated() {
        if Thread.isMainThread { loadData() } else { DispatchQueue.main.async { [weak self] in self?.loadData() } }
    }

    // MARK: - Collection view setup

    private func setupCollectionView() {
        collectionView.register(
            UINib(nibName: "HydrationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "HydrationCell"
        )
        collectionView.register(
            UINib(nibName: "MedicationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "MedicationCell"
        )
        collectionView.register(
            UINib(nibName: "SymptomCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SymptomCell"
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        layout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = layout
    }

    private func setupObservers() {
        [Notification.Name.hydrationDataUpdated,
         .medicationDataUpdated, .symptomDataUpdated, .exerciseDataUpdated].forEach {
            NotificationCenter.default.addObserver(
                self, selector: #selector(handleCareDataUpdated), name: $0, object: nil
            )
        }
    }

    func presentationControllerDidDismiss(_: UIPresentationController) {
        loadData()
    }
}

// MARK: - UICollectionViewDataSource

extension HealthInsightsViewController: UICollectionViewDataSource {
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        healthInsights.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let insight = healthInsights[indexPath.item]
        let filterDates = insightBuilder.resolveDates(for: activeFilter)

        switch insight.type {
        case .hydration: return configureHydrationCell(collectionView, at: indexPath, insight: insight)
        case .exercise: return configureExerciseCell(collectionView, at: indexPath, insight: insight)
        case .medication: return configureMedicationCell(collectionView, at: indexPath, insight: insight, filterDates: filterDates)
        case .symptoms: return configureSymptomsCell(collectionView, at: indexPath, insight: insight, filterDates: filterDates)
        default: return UICollectionViewCell()
        }
    }

    private func configureHydrationCell(_ collectionView: UICollectionView, at indexPath: IndexPath, insight: HealthInsight) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HydrationCell", for: indexPath) as? HydrationCollectionViewCell else {
            fatalError("Expected HydrationCollectionViewCell for reuse identifier 'HydrationCell' at \(indexPath)")
        }
        cell.titleLabel.text = insight.title
        cell.subtitleLabel.text = insight.subtitle
        cell.subtitle2Label.text = insight.completedValue
        cell.averageValueLabel.text = insight.mainValue
        cell.hydrationGraphView.graphType = .hydration
        cell.hydrationGraphView.dataPoints = insight.dailyValues ?? []
        cell.hydrationGraphView.valueFormatter = { insight.formatGraphValue($0) }
        cell.hydrationGraphView.popupTextProvider = nil
        cell.hydrationGraphView.popupTextAlignment = .center
        return cell
    }

    private func configureExerciseCell(_ collectionView: UICollectionView, at indexPath: IndexPath, insight: HealthInsight) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCell", for: indexPath) as? MedicationCollectionViewCell else {
            fatalError("Expected MedicationCollectionViewCell for reuse identifier 'MedicationCell' at \(indexPath)")
        }
        cell.titleLabel.text = insight.title
        cell.subtitleLabel.text = insight.subtitle
        cell.adherenceRateLabel.text = insight.mainValue
        cell.metricCaptionLabel.text = insight.secondaryValue
        cell.dosesTakenLabel.text = insight.medicationTaken
        cell.dosesMissedLabel.text = insight.medicationMissed
        cell.configureStatusIcons(
            with: insight.dailyValues ?? [],
            isSelectionEnabled: false,
            usesDashedPlaceholderForIncompleteDays: true
        )
        cell.onStatusIconTapped = nil
        return cell
    }

    private func configureMedicationCell(_ collectionView: UICollectionView, at indexPath: IndexPath, insight: HealthInsight, filterDates: [Date]) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCell", for: indexPath) as? MedicationCollectionViewCell else {
            fatalError("Expected MedicationCollectionViewCell for reuse identifier 'MedicationCell' at \(indexPath)")
        }
        cell.titleLabel.text = insight.title
        cell.subtitleLabel.text = insight.subtitle
        cell.adherenceRateLabel.text = insight.mainValue
        cell.metricCaptionLabel.text = "Adherence rate"
        cell.dosesTakenLabel.text = insight.medicationTaken
        cell.dosesMissedLabel.text = insight.medicationMissed
        let selectedMedIndex = shouldHighlightMedicationSelection
            ? selectedIndex(for: selectedMedicationDate, within: filterDates) : nil
        cell.configureStatusIcons(
            with: insight.dailyValues ?? [],
            selectedIndex: selectedMedIndex,
            isSelectionEnabled: true
        )
        cell.onStatusIconTapped = { [weak self] index in
            guard let self, index < filterDates.count else { return }
            self.selectedMedicationDate = filterDates[index]
            self.shouldHighlightMedicationSelection = true
        }
        return cell
    }

    private func configureSymptomsCell(_ collectionView: UICollectionView, at indexPath: IndexPath, insight: HealthInsight, filterDates: [Date]) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomCell", for: indexPath) as? SymptomCollectionViewCell else {
            fatalError("Expected SymptomCollectionViewCell for reuse identifier 'SymptomCell' at \(indexPath)")
        }
        cell.titleLabel.text = insight.title
        cell.subtitleLabel.text = insight.subtitle
        cell.footerLabel?.text = insight.detailText
        cell.symptomsGraphView.graphType = .symptoms
        cell.symptomsGraphView.dataPoints = insight.dailyValues ?? []
        cell.symptomsGraphView.valueFormatter = { insight.formatGraphValue($0) }
        cell.symptomsGraphView.popupTextAlignment = .left
        cell.symptomsGraphView.popupTextProvider = { [filterDates] index in
            guard index < filterDates.count else { return nil }
            return Self.makeSymptomsPopupText(for: filterDates[index])
        }
        cell.symptomsGraphView.onDataPointSelected = { [weak self] index in
            guard let self, index < filterDates.count else { return }
            self.presentSymptomsDetail(for: filterDates[index])
        }
        if shouldHighlightSymptomSelection,
           let selIdx = selectedIndex(for: selectedSymptomDate, within: filterDates) {
            DispatchQueue.main.async { cell.symptomsGraphView.selectPoint(at: selIdx) }
        } else {
            cell.symptomsGraphView.selectPoint(at: nil)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HealthInsightsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.frame.width - 32, height: 320)
    }

    func collectionView(
        _: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch healthInsights[indexPath.item].type {
        case .hydration: break
        case .exercise: break
        case .medication: presentMedicationDetail(for: selectedMedicationDate)
        case .symptoms: presentSymptomsDetail(for: selectedSymptomDate)
        }
    }
}

// MARK: - Detail navigation

extension HealthInsightsViewController {
    private func presentHydrationDetail() {
        let sb = UIStoryboard(name: "Insights", bundle: nil)
        guard let vc = sb.instantiateViewController(
            withIdentifier: "HydrationDetailViewController"
        ) as? HydrationDetailViewController else { return }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(nav, animated: true)
    }

    private func presentMedicationDetail(for date: Date) {
        let sb = UIStoryboard(name: "Medication", bundle: nil)
        guard let vc = sb.instantiateViewController(
            withIdentifier: "MedicationViewController"
        ) as? MedicationViewController else { return }
        let selectedDate = calendar.startOfDay(for: date)
        selectedMedicationDate = selectedDate
        shouldHighlightMedicationSelection = true
        vc.displayDate = selectedDate
        vc.onDismiss = { [weak self] in self?.loadData() }
        presentSheet(rootViewController: vc)
    }

    private func presentSymptomsDetail(for date: Date) {
        let sb = UIStoryboard(name: "symptomMain", bundle: nil)
        guard let vc = sb.instantiateViewController(
            withIdentifier: "SymptomsViewController"
        ) as? SymptomsViewController else { return }
        let selectedDate = calendar.startOfDay(for: date)
        selectedSymptomDate = selectedDate
        shouldHighlightSymptomSelection = true
        vc.displayDate = selectedDate
        vc.onDismiss = { [weak self] in self?.loadData() }
        presentSheet(rootViewController: vc)
    }

    private func presentSheet(rootViewController: UIViewController) {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.modalPresentationStyle = .pageSheet
        nav.presentationController?.delegate = self
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }
        present(nav, animated: true)
    }
}

// MARK: - Date utilities

private extension HealthInsightsViewController {
    func normalizeSelectedDates() {
        let dates = insightBuilder.resolveDates(for: activeFilter)
        let today = calendar.startOfDay(for: Date())
        if !contains(selectedMedicationDate, within: dates) {
            selectedMedicationDate = today
            shouldHighlightMedicationSelection = false
        }
        if !contains(selectedSymptomDate, within: dates) {
            selectedSymptomDate = today
            shouldHighlightSymptomSelection = false
        }
    }

    func selectedIndex(for date: Date, within dates: [Date]) -> Int? {
        dates.firstIndex { calendar.isDate($0, inSameDayAs: date) }
    }

    func contains(_ date: Date, within dates: [Date]) -> Bool {
        selectedIndex(for: date, within: dates) != nil
    }

    static func makeSymptomsPopupText(for date: Date) -> NSAttributedString {
        let logs = SymptomDataSource.shared.getSymptomLogs(on: date)
        let primaryColor = UIColor(named: "primary_color")
            ?? UIColor(named: "PrimaryColor")
            ?? UIColor(named: "pink")
            ?? .systemPink
        let orderedNames = logs.reduce(into: [String]()) { names, log in
            if !names.contains(log.symptomName) { names.append(log.symptomName) }
        }
        let summaries = orderedNames.compactMap { name -> (name: String, severity: Int)? in
            logs.filter { $0.symptomName == name }.map(\.severity).max().map { (name, $0) }
        }
        let fmt = DateFormatter(); fmt.dateFormat = "EEE"
        let titleSty = NSMutableParagraphStyle()
        titleSty.alignment = .left; titleSty.lineSpacing = 4
        let bodySty = NSMutableParagraphStyle()
        bodySty.alignment = .left; bodySty.lineSpacing = 6
        let result = NSMutableAttributedString(
            string: "\(fmt.string(from: date))\n",
            attributes: [.foregroundColor: UIColor.label,
                         .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                         .paragraphStyle: titleSty]
        )
        if logs.isEmpty {
            result.append(NSAttributedString(
                string: "No symptoms logged",
                attributes: [.foregroundColor: primaryColor,
                             .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                             .paragraphStyle: bodySty]
            ))
            return result
        }
        for (i, s) in summaries.enumerated() {
            result.append(NSAttributedString(
                string: "\(s.name) : \(s.severity)",
                attributes: [.foregroundColor: primaryColor,
                             .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                             .paragraphStyle: bodySty]
            ))
            if i < summaries.count - 1 { result.append(NSAttributedString(string: "\n")) }
        }
        return result
    }
}
