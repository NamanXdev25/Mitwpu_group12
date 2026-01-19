import UIKit

protocol LogsTrackingCellDelegate: AnyObject {
    func didTapTrackingCell(with model: HealthTrackingModel)
}

class LogsTrackingCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    
    weak var delegate: LogsTrackingCellDelegate?
    private var currentModel: HealthTrackingModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
    }
    
    @objc private func cellTapped() {
        guard let model = currentModel else { return }
        delegate?.didTapTrackingCell(with: model)
    }
    
    func configure(with model: HealthTrackingModel) {
        self.currentModel = model
        titleLabel.text = model.title
        subtitleLabel.text = model.displayLastTracked
        iconImageView.image = UIImage(systemName: model.iconName)
    }
}
