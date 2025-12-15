import UIKit

class LogsStatsRowCell: UICollectionViewCell {
    
    // --- HYDRATION OUTLETS ---
    @IBOutlet weak var hydrationContainer: UIView!
    @IBOutlet weak var hydrationTitle: UILabel!
    @IBOutlet weak var hydrationValue: UILabel!
    @IBOutlet weak var hydrationSubtitle: UILabel!
    @IBOutlet weak var hydrationProgress: UIProgressView!
    @IBOutlet weak var hydrationChevron: UIButton!
    
    // --- EXERCISE OUTLETS ---
    @IBOutlet weak var exerciseContainer: UIView!
    @IBOutlet weak var exerciseTitle: UILabel!
    @IBOutlet weak var exerciseValue: UILabel!
    @IBOutlet weak var exerciseSubtitle: UILabel!
    @IBOutlet weak var exerciseProgress: UIProgressView!
    @IBOutlet weak var exerciseChevron: UIButton!
    
    private let pinkColor = UIColor(named: "TabBarcolour")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: StatsModel) {
        // Hydration
        hydrationTitle.text = model.hydration.title
        hydrationValue.text = model.hydration.displayValue
        hydrationSubtitle.text = model.hydration.displaySubtitle
        hydrationProgress.progress = model.hydration.progress
        hydrationProgress.progressTintColor = pinkColor
        
        // Exercise
        exerciseTitle.text = model.exercise.title
        exerciseValue.text = model.exercise.displayValue
        exerciseSubtitle.text = model.exercise.displaySubtitle
        exerciseProgress.progress = model.exercise.progress
        exerciseProgress.progressTintColor = pinkColor
    }
}
