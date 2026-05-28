import UIKit

protocol CareViewInsightsCellDelegate: AnyObject {
    func careViewInsightsCellDidTap(_ cell: CareViewInsightsCell)
}

class CareViewInsightsCell: UICollectionViewCell {
    @IBOutlet var InsightsContainer: UIView!
    @IBOutlet var InsightCellImage: UIImageView!
    @IBOutlet var InsightCellChevronButton: UIButton!
    @IBOutlet var InsightCellLabel: UILabel!

    weak var delegate: CareViewInsightsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        delegate?.careViewInsightsCellDidTap(self)
    }
}
