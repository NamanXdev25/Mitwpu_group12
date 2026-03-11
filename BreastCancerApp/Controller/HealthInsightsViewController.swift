import UIKit

class HealthInsightsViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    var healthInsights: [HealthInsight] = []
    private let insightBuilder = HealthInsightBuilder()
    private let calendar = Calendar.current
    private var selectedMedicationDate = Calendar.current.startOfDay(for: Date())
    private var selectedSymptomDate = Calendar.current.startOfDay(for: Date())
    private var shouldHighlightMedicationSelection = false
    private var shouldHighlightSymptomSelection = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupCollectionView() {
        
        let hydrationNib = UINib(nibName: "HydrationCollectionViewCell", bundle: nil)
        collectionView.register(hydrationNib, forCellWithReuseIdentifier: "HydrationCell")
        
        let medicationNib = UINib(nibName: "MedicationCollectionViewCell", bundle: nil)
        collectionView.register(medicationNib, forCellWithReuseIdentifier: "MedicationCell")
        
        let symptomNib = UINib(nibName: "SymptomCollectionViewCell", bundle: nil)
        collectionView.register(symptomNib, forCellWithReuseIdentifier: "SymptomCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        layout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = layout
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCareDataUpdated),
            name: .hydrationDataUpdated,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCareDataUpdated),
            name: .medicationDataUpdated,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCareDataUpdated),
            name: .symptomDataUpdated,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCareDataUpdated),
            name: .exerciseDataUpdated,
            object: nil
        )
    }
    
    private func loadData() {
        normalizeSelectedDates()
        healthInsights = insightBuilder.buildInsights()
        collectionView.reloadData()
    }

    @objc private func handleCareDataUpdated() {
        if Thread.isMainThread {
            loadData()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.loadData()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HealthInsightsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return healthInsights.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let insight = healthInsights[indexPath.item]
        
        switch insight.type {
        case .hydration:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HydrationCell", for: indexPath) as! HydrationCollectionViewCell
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
            
        case .exercise:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCell", for: indexPath) as! MedicationCollectionViewCell
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
            
        case .medication:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCell", for: indexPath) as! MedicationCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.adherenceRateLabel.text = insight.mainValue
            cell.metricCaptionLabel.text = "Adherence rate"
            cell.dosesTakenLabel.text = insight.medicationTaken
            cell.dosesMissedLabel.text = insight.medicationMissed
            let weekDates = currentWeekDates()
            let selectedMedicationIndex = shouldHighlightMedicationSelection
                ? selectedIndex(for: selectedMedicationDate, within: weekDates)
                : nil

            cell.configureStatusIcons(
                with: insight.dailyValues ?? [],
                selectedIndex: selectedMedicationIndex,
                isSelectionEnabled: true
            )
            cell.onStatusIconTapped = { [weak self] index in
                guard let self = self, index < weekDates.count else { return }
                self.selectedMedicationDate = weekDates[index]
                self.shouldHighlightMedicationSelection = true
            }
            return cell
            
        case .symptoms:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomCell", for: indexPath) as! SymptomCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.footerLabel?.text = insight.detailText
            cell.symptomsGraphView.graphType = .symptoms
            cell.symptomsGraphView.dataPoints = insight.dailyValues ?? []
            let weekDates = currentWeekDates()
            
            cell.symptomsGraphView.valueFormatter = { value in
                return insight.formatGraphValue(value)
            }
            cell.symptomsGraphView.popupTextAlignment = .left
            cell.symptomsGraphView.popupTextProvider = { [weekDates] index in
                guard index < weekDates.count else { return nil }
                return Self.makeSymptomsPopupText(for: weekDates[index])
            }
            cell.symptomsGraphView.onDataPointSelected = { [weak self] index in
                guard let self = self, index < weekDates.count else { return }
                self.selectedSymptomDate = weekDates[index]
                self.shouldHighlightSymptomSelection = true
            }

            if shouldHighlightSymptomSelection,
               let selectedIndex = selectedIndex(for: selectedSymptomDate, within: weekDates) {
                DispatchQueue.main.async {
                    cell.symptomsGraphView.selectPoint(at: selectedIndex)
                }
            } else {
                cell.symptomsGraphView.selectPoint(at: nil)
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension HealthInsightsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let insight = healthInsights[indexPath.item]
        
        switch insight.type {
        case .symptoms, .exercise, .hydration, .medication:
            
            return CGSize(width: width, height: 320)
        default:
            return CGSize(width: width, height: 320)
        }
    }
    
    // MARK: - Cell Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let insight = healthInsights[indexPath.item]
        
        switch insight.type {
        case .hydration:
            presentHydrationDetail()
        case .exercise:
            // TODO: Implement exercise detail
            break
        case .medication:
            presentMedicationDetail(for: selectedMedicationDate)
        case .symptoms:
            presentSymptomsDetail(for: selectedSymptomDate)
        }
    }
    
    // MARK: - Navigation
    private func presentHydrationDetail() {
        // Instantiate the view controller from storyboard
        let storyboard = UIStoryboard(name: "Insights", bundle: nil)
        
        guard let hydrationVC = storyboard.instantiateViewController(withIdentifier: "HydrationDetailViewController") as? HydrationDetailViewController else {
            print("Error: Could not instantiate HydrationDetailViewController")
            return
        }
        
        // Embed in navigation controller
        let navController = UINavigationController(rootViewController: hydrationVC)
        navController.modalPresentationStyle = .pageSheet
        
        // Configure sheet presentation (iOS 15+)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(navController, animated: true)
    }

    private func presentMedicationDetail(for date: Date) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)

        guard let medicationVC = storyboard.instantiateViewController(
            withIdentifier: "MedicationViewController"
        ) as? MedicationViewController else {
            print("Error: Could not instantiate MedicationViewController")
            return
        }

        let selectedDate = calendar.startOfDay(for: date)
        selectedMedicationDate = selectedDate
        shouldHighlightMedicationSelection = true
        medicationVC.displayDate = selectedDate
        medicationVC.onDismiss = { [weak self] in
            self?.loadData()
        }
        presentSheet(rootViewController: medicationVC)
    }

    private func presentSymptomsDetail(for date: Date) {
        let storyboard = UIStoryboard(name: "symptomMain", bundle: nil)

        guard let symptomsVC = storyboard.instantiateViewController(
            withIdentifier: "SymptomsViewController"
        ) as? SymptomsViewController else {
            print("Error: Could not instantiate SymptomsViewController")
            return
        }

        let selectedDate = calendar.startOfDay(for: date)
        selectedSymptomDate = selectedDate
        shouldHighlightSymptomSelection = true
        symptomsVC.displayDate = selectedDate
        symptomsVC.onDismiss = { [weak self] in
            self?.loadData()
        }
        presentSheet(rootViewController: symptomsVC)
    }

    private func presentSheet(rootViewController: UIViewController) {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.modalPresentationStyle = .pageSheet
        navController.presentationController?.delegate = self

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }

        present(navController, animated: true)
    }

    private func currentWeekDates() -> [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today) ?? today

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: monday)
        }
    }

    private func normalizeSelectedDates() {
        let weekDates = currentWeekDates()
        let today = calendar.startOfDay(for: Date())

        if !contains(selectedMedicationDate, within: weekDates) {
            selectedMedicationDate = today
            shouldHighlightMedicationSelection = false
        }

        if !contains(selectedSymptomDate, within: weekDates) {
            selectedSymptomDate = today
            shouldHighlightSymptomSelection = false
        }
    }

    private func selectedIndex(for date: Date, within dates: [Date]) -> Int? {
        dates.firstIndex { calendar.isDate($0, inSameDayAs: date) }
    }

    private func contains(_ date: Date, within dates: [Date]) -> Bool {
        selectedIndex(for: date, within: dates) != nil
    }

    private static func makeSymptomsPopupText(for date: Date) -> NSAttributedString {
        let logs = SymptomDataSource.shared.getSymptomLogs(on: date)
        let primaryColor = UIColor(named: "primary_color")
            ?? UIColor(named: "PrimaryColor")
            ?? UIColor(named: "pink")
            ?? .systemPink
        let orderedSymptomNames = logs.reduce(into: [String]()) { names, log in
            if !names.contains(log.symptomName) {
                names.append(log.symptomName)
            }
        }
        let symptomSummaries = orderedSymptomNames.compactMap { symptomName -> (name: String, severity: Int)? in
            let matchingLogs = logs.filter { $0.symptomName == symptomName }
            guard let highestSeverity = matchingLogs.map(\.severity).max() else { return nil }
            return (name: symptomName, severity: highestSeverity)
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        let dayText = dayFormatter.string(from: date)

        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .left
        titleStyle.lineSpacing = 4

        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.alignment = .left
        bodyStyle.lineSpacing = 6

        let attributedText = NSMutableAttributedString(string: "\(dayText)\n", attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .paragraphStyle: titleStyle
        ])

        if logs.isEmpty {
            attributedText.append(NSAttributedString(string: "No symptoms logged", attributes: [
                .foregroundColor: primaryColor,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .paragraphStyle: bodyStyle
            ]))
            return attributedText
        }

        for (index, summary) in symptomSummaries.enumerated() {
            let line = "\(summary.name) : \(summary.severity)"
            attributedText.append(NSAttributedString(string: line, attributes: [
                .foregroundColor: primaryColor,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .paragraphStyle: bodyStyle
            ]))

            if index < symptomSummaries.count - 1 {
                attributedText.append(NSAttributedString(string: "\n"))
            }
        }

        return attributedText
    }
}

extension HealthInsightsViewController {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        loadData()
    }
}
