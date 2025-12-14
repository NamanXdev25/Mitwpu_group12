import UIKit

class StatsRowCell: UICollectionViewCell {
    static let identifier = "StatsRowCell"
    
    // --- HYDRATION OUTLETS ---
    @IBOutlet weak var hydrationContainer: UIView!
    @IBOutlet weak var hydrationTitle: UILabel!
    @IBOutlet weak var hydrationValue: UILabel!
    @IBOutlet weak var hydrationSubtitle: UILabel!
    @IBOutlet weak var hydrationProgress: UIProgressView!
    @IBOutlet weak var hydrationChevron: UIButton! // Connect this!
    
    // --- EXERCISE OUTLETS ---
    @IBOutlet weak var exerciseContainer: UIView!
    @IBOutlet weak var exerciseTitle: UILabel!
    @IBOutlet weak var exerciseValue: UILabel!
    @IBOutlet weak var exerciseSubtitle: UILabel!
    @IBOutlet weak var exerciseProgress: UIProgressView!
    @IBOutlet weak var exerciseChevron: UIButton! // Connect this!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardDesign()
        setupChevronStyle()
    }
    
    func configure() {
        let pinkColor = UIColor(red: 0.910, green: 0.416, blue: 0.573, alpha: 1.0)
        
        // Hydration Data
        hydrationTitle.text = "Hydration"
        hydrationValue.text = "1.8"
        hydrationSubtitle.text = "of 3L Completed"
        hydrationProgress.progress = 0.6
        hydrationProgress.progressTintColor = pinkColor
        
        // Exercise Data
        exerciseTitle.text = "Exercise"
        exerciseValue.text = "2"
        exerciseSubtitle.text = "of 4 Done"
        exerciseProgress.progress = 0.5
        exerciseProgress.progressTintColor = pinkColor
    }
    
    private func setupCardDesign() {
        [hydrationContainer, exerciseContainer].forEach { view in
            view?.layer.cornerRadius = 13
            view?.backgroundColor = .white
        }
    }
    
    private func setupChevronStyle() {
        // Exact styling to match your screenshot
        // 1. Create a configuration for specific weight and scale
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium, scale: .small)
        let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: config)
        
        [hydrationChevron, exerciseChevron].forEach { button in
            // 2. Set the image
            button?.setImage(chevronImage, for: .normal)
            
            // 3. Set exact color (Black/Dark Gray)
            button?.tintColor = .black
            
            // 4. Clear default title if any
            button?.setTitle("", for: .normal)
        }
    }
}
