import UIKit

class PlanCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    // --- NEW OUTLET ---
    @IBOutlet weak var clockIcon: UIImageView!
    
    var onToggle: (() -> Void)?
    var onNavigate: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.layer.borderWidth = 2
        checkButton.layer.borderColor = UIColor.systemGray4.cgColor
        checkButton.layer.cornerRadius = checkButton.bounds.height / 2
        checkButton.clipsToBounds = true
    }

    @IBAction func checkButtonTapped(_ sender: Any) {
        onToggle?()
    }
    
    func configure(with item: PlanItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        timeLabel.text = item.time
        
        let checkcolor = UIColor(named: "plusbuttoncolor")!
        
        if item.isCompleted {
            checkButton.backgroundColor = checkcolor
            checkButton.layer.borderWidth = 0

            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
            let image = UIImage(systemName: "checkmark", withConfiguration: config)

            checkButton.setImage(image, for: .normal)
            checkButton.tintColor = .white
        } else {
            checkButton.backgroundColor = .clear
            checkButton.layer.borderWidth = 2
            checkButton.setImage(nil, for: .normal)
        }
    }
}



