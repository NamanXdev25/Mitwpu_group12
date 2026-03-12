
import UIKit

class HomeJournalCell: UICollectionViewCell {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var StartwritingLabel: UILabel!
    @IBOutlet weak var micbutton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with suggestion: Suggestion) {
        TitleLabel.text = suggestion.title
        StartwritingLabel.text = "Start Writing..."
    }
}
