
import UIKit

class HomeQuoteCell: UICollectionViewCell {

    @IBOutlet weak var QuoteView: UIView!
    @IBOutlet weak var QuoteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Configure
    func configure(quote: String) {
        QuoteLabel.text = quote
    }
}
