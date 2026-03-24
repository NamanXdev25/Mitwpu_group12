import UIKit

class ExerciseInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var onInfoTap: ((_ infoButton: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        
        if let btn = sender as? UIButton {
            onInfoTap?(btn)
        } else {
            onInfoTap?(infoButton)
        }
    }
}

