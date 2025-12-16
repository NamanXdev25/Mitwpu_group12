import UIKit

class LogsSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var manageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: SectionHeaderModel) {
        titleLabel.text = model.title
        manageButton.isHidden = !model.showManageButton
    }
}
