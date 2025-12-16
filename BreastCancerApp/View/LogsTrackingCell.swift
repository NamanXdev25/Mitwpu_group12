import UIKit

protocol LogsTrackingCellDelegate: AnyObject {
    func didTapSelfExam(with model: HealthTrackingModel)
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
    
    func configure(with model: HealthTrackingModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.displayLastTracked
        iconImageView.image = UIImage(systemName: model.iconName)
        currentModel = model  // Add this line - it was missing!
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    @objc private func cellTapped() {
        if let model = currentModel {
            delegate?.didTapSelfExam(with: model)
        }
    }
}
