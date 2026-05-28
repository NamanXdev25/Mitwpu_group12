import UIKit

class HomeJournalCell: UICollectionViewCell {
    @IBOutlet var TitleLabel: UILabel!
    @IBOutlet var StartwritingLabel: UILabel!

    func configure(with suggestion: Suggestion) {
        TitleLabel.text = suggestion.title
        StartwritingLabel.text = "Start Writing..."
    }
}
