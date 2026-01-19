import UIKit

protocol LogsSectionHeaderDelegate: AnyObject {
    func didTapManageButton(for section: Int)
}

class LogsSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var manageButton: UIButton!
    
    weak var delegate: LogsSectionHeaderDelegate?
    private var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        manageButton.addTarget(self, action: #selector(manageButtonTapped), for: .touchUpInside)
    }
    
    @objc private func manageButtonTapped() {
        delegate?.didTapManageButton(for: section)
    }
    
    func configure(with model: SectionHeaderModel, section: Int) {
        self.section = section
        titleLabel.text = model.title
        manageButton.isHidden = !model.showManageButton
    }
}
