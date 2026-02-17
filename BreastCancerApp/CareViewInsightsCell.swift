import UIKit

protocol CareViewInsightsCellDelegate: AnyObject {
    func careViewInsightsCellDidTap(_ cell: CareViewInsightsCell)
}

class CareViewInsightsCell: UICollectionViewCell {

    @IBOutlet weak var InsightsContainer: UIView!
    @IBOutlet weak var InsightCellImage: UIImageView!
    @IBOutlet weak var InsightCellChevronButton: UIButton!
    @IBOutlet weak var InsightCellLabel: UILabel!
    
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
