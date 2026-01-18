import UIKit

class WarningCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.borderWidth = 1
        
        let containerColor = UIColor(named: "WarningBorderColor")
        containerView.layer.borderColor = containerColor?.cgColor
    }
    
    func setup(message: String) {
        warningLabel.text = message
    }
}
