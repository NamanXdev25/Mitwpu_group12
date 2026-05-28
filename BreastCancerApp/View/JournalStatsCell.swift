import UIKit

class JournalStatsCell: UICollectionViewCell {
    static let reuseIdentifier = "JournalStatsCell"

    @IBOutlet var totalCountLabel: UILabel!
    @IBOutlet var totalSubtitleLabel: UILabel!
    @IBOutlet var weekCountLabel: UILabel!
    @IBOutlet var weekSubtitleLabel: UILabel!

    func configure(total: Int, thisWeek: Int) {
        totalCountLabel.text = "\(total)"
        totalSubtitleLabel.text = "Total Journals"
        weekCountLabel.text = "\(thisWeek)"
        weekSubtitleLabel.text = "This Week"
    }
}
