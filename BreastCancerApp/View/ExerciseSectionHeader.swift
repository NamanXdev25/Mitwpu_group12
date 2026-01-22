import UIKit

class ExerciseSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(status: String) {
        statusLabel.text = status
    }
}
