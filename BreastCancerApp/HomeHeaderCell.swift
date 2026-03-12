
import UIKit

class HomeHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var HeaderTitleLabel: UILabel!
    @IBOutlet weak var seeAllLabel: UILabel!
    
    var onSeeAllTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seeAllLabelTapped))
        seeAllLabel.isUserInteractionEnabled = true
        seeAllLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Configure
    func configure(title: String, showSeeAll: Bool = false) {
        HeaderTitleLabel.text = title
        seeAllLabel.isHidden = !showSeeAll
    }
    
    @objc private func seeAllLabelTapped() {
        onSeeAllTapped?()
    }
}
