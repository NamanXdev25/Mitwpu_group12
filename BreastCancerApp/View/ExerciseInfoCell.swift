import UIKit

class ExerciseInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var levelBackgroundView: UIView!
    
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
        print("Info button tapped")
        
        if let btn = sender as? UIButton {
            onInfoTap?(btn)
        } else {
            onInfoTap?(infoButton)
        }
    }
}

