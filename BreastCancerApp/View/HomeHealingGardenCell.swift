import UIKit

class HomeHealingGardenCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var ChevronButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var currentProgressLabel: UILabel!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var totalGoalLabel: UILabel!       
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func ChevronTapped(_ sender: Any) {
    }
    
    
}
