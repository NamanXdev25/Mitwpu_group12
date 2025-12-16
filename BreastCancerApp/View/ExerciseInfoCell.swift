import UIKit

class ExerciseInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var levelBackgroundView: UIView!
    // NEW: closure that the controller will set to handle info taps.
    // Passes the button so the controller can anchor popover to it.
    var onInfoTap: ((_ infoButton: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       // self.backgroundColor = .clear
        
        // Title - Bold and prominent
        //titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        //titleLabel.textColor = .black
        //titleLabel.numberOfLines = 0
        
        // Info button - Pink circular
//        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
//        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: config), for: .normal)
//        infoButton.tintColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
        
//        // Description - Gray, readable
//        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
//        descriptionLabel.textColor = UIColor.darkGray
//        descriptionLabel.numberOfLines = 0
//        
//        // Level badge - Subtle, darker text
//        levelLabel.font = .systemFont(ofSize: 12, weight: .semibold)
//        levelLabel.textColor = .beginner
        
//        // The view you added behind the label (connect as outlet: levelBackgroundView)
//           levelBackgroundView.backgroundColor = UIColor(red: 1.0, green: 0.90, blue: 0.93, alpha: 1.0) // soft pink
//           levelBackgroundView.layer.cornerRadius = 10
//           levelBackgroundView.layer.masksToBounds = true
    }
    
    func configure(title: String, description: String, level: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        levelLabel.text = level
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        // Keep the debug print (optional)
        print("Info button tapped")
        // Call the controller-provided closure so the controller handles presentation
        if let btn = sender as? UIButton {
            onInfoTap?(btn)
        } else {
            // fallback: pass the infoButton outlet
            onInfoTap?(infoButton)
        }
    }
}

