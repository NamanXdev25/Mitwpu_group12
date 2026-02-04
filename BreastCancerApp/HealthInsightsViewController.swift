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
        
        let moodNib = UINib(nibName: "MoodGardenCollectionViewCell", bundle: nil)
        collectionView.register(moodNib, forCellWithReuseIdentifier: "MoodCell")
        
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 320)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        layout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = layout
    }
    
    private func loadData() {
        self.healthInsights = HealthInsightResponse.loadFromFile()
        self.collectionView.reloadData()
    }
}

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
            return cell
            
        case .exercise:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as! ExerciseCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.dayActiveValueLabel?.text = insight.secondaryValue
            cell.totalMinutesValueLabel?.text = insight.mainValue
            return cell
            
        case .medication:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCell", for: indexPath) as! MedicationCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.adherenceRateLabel.text = insight.mainValue
            cell.dosesTakenLabel.text = insight.medicationTaken
            cell.dosesMissedLabel.text = insight.medicationMissed
            return cell
            
        case .symptoms:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymptomCell", for: indexPath) as! SymptomCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            cell.footerLabel?.text = insight.detailText
            return cell
            
        case .mood:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoodCell", for: indexPath) as! MoodGardenCollectionViewCell
            cell.titleLabel.text = insight.title
            cell.subtitleLabel.text = insight.subtitle
            // detailText in your JSON contains "View History"
            cell.viewHistoryButton.setTitle(insight.detailText, for: .normal)
            
            // NEW: Pass the mood data to draw the flowers!
            cell.setupGarden(with: insight.moodValues)
            
            return cell
        }
    }

}

extension HealthInsightsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let insight = healthInsights[indexPath.item]
        
        switch insight.type {
        case .mood:
            return CGSize(width: width, height: 480) // Taller for the garden
        case .symptoms:
            return CGSize(width: width, height: 380) // Taller for the triple graph
        default:
            return CGSize(width: width, height: 320) // Standard for others
        }
    }
}
