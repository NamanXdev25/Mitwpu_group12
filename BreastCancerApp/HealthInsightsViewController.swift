import UIKit

class HealthInsightsViewController: UIViewController {
    
    var healthInsights: [HealthInsight] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupCollectionView()
        loadData()
        
    }
    
    private func setupCollectionView() {
        
        let hydrationNib = UINib(nibName: "HydrationCollectionViewCell", bundle: nil)
        collectionView.register(hydrationNib, forCellWithReuseIdentifier: "HydrationCell")
        
        let exerciseNib = UINib(nibName: "ExerciseCollectionViewCell", bundle: nil)
        collectionView.register(exerciseNib, forCellWithReuseIdentifier: "ExerciseCell")
        
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
    
    private func loadData() {
        self.healthInsights = HealthInsightResponse.loadFromFile()
        self.collectionView.reloadData()
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
            
            return cell
            
        case .exercise:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as! ExerciseCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.dayActiveValueLabel?.text = insight.secondaryValue
            cell.totalMinutesValueLabel?.text = insight.mainValue
            
            // Pass daily values from JSON to the bar graph
            cell.exerciseGraphView.dataPoints = insight.dailyValues ?? []
            return cell
            
        case .medication:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCell", for: indexPath) as! MedicationCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.adherenceRateLabel.text = insight.mainValue
            cell.dosesTakenLabel.text = insight.medicationTaken
            cell.dosesMissedLabel.text = insight.medicationMissed
        
            if let values = insight.dailyValues {
                for (index, icon) in cell.statusIcons.enumerated() where index < values.count {
                    let isTaken = values[index] == 1
                    icon.image = UIImage(systemName: isTaken ? "checkmark.circle.fill" : "circle.fill")
                    icon.tintColor = isTaken ? UIColor.systemPink : UIColor.systemGray4
                }
            }
            return cell
            
        case .symptoms:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomCell", for: indexPath) as! SymptomCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.footerLabel?.text = insight.detailText
            cell.symptomsGraphView.graphType = .symptoms
            cell.symptomsGraphView.dataPoints = insight.dailyValues ?? []
            
            cell.symptomsGraphView.valueFormatter = { value in
                return insight.formatGraphValue(value)
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
            // TODO: Implement medication detail
            break
        case .symptoms:
            // TODO: Implement symptoms detail
            break
        }
    }
    
    // MARK: - Navigation
    private func presentHydrationDetail() {
        // Instantiate the view controller from storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
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
}
