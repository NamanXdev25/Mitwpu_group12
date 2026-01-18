import UIKit

final class YearFilterCell: UICollectionViewCell {

    static let reuseIdentifier = "YearFilterCell"

    @IBOutlet weak var yearButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        yearButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
    }
}
