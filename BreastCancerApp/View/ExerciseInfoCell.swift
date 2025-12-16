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

