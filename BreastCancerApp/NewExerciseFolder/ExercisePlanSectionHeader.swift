
import UIKit

class ExercisePlanSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String) {
        sectionTitleLabel.text = title
    }
}
