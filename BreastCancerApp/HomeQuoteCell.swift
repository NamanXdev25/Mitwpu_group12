import UIKit

class HomeQuoteCell: UICollectionViewCell {
    @IBOutlet var QuoteView: UIView!
    @IBOutlet var QuoteLabel: UILabel!

    // MARK: - Configure

    func configure(quote: String) {
        QuoteLabel.text = quote
    }
}
