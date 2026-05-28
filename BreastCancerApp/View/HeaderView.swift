import UIKit

class HeaderView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!

    func configureHeader(text: String) {
        titleLabel.text = text
    }
}
