import UIKit

protocol LogsStatsRowCellDelegate: AnyObject {
    func didTapExercise()
    func didTapHydration()
}

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
    
    weak var delegate: LogsStatsRowCellDelegate?
        
        // Your existing code and outlets...
        
        // Add this method - call it from your configure method or awakeFromNib
        func setupTapGestures() {
            // Replace 'exerciseView' and 'hydrationView' with your actual outlet names
            let exerciseTap = UITapGestureRecognizer(target: self, action: #selector(exerciseTapped))
            exerciseContainer.addGestureRecognizer(exerciseTap)
            exerciseContainer.isUserInteractionEnabled = true
            
            let hydrationTap = UITapGestureRecognizer(target: self, action: #selector(hydrationTapped))
            hydrationContainer.addGestureRecognizer(hydrationTap)
            hydrationContainer.isUserInteractionEnabled = true
        }
        
        @objc private func exerciseTapped() {
            delegate?.didTapExercise()
        }
        
        @objc private func hydrationTapped() {
            delegate?.didTapHydration()
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGestures()
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
