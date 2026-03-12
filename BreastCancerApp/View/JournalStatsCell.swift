
import UIKit

class JournalStatsCell: UICollectionViewCell {

    static let reuseIdentifier = "JournalStatsCell"
    
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var totalSubtitleLabel: UILabel!
    @IBOutlet weak var weekCountLabel: UILabel!
    @IBOutlet weak var weekSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(total: Int, thisWeek: Int) {
            totalCountLabel.text = "\(total)"
            totalSubtitleLabel.text = "Total Journals"
            weekCountLabel.text = "\(thisWeek)"
            weekSubtitleLabel.text = "This Week"
    }

}
