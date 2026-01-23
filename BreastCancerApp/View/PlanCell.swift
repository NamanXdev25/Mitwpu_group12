import UIKit

class PlanCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var clockIcon: UIImageView!
    
    var onToggle: (() -> Void)?
    var onNavigate: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.layer.borderWidth = 2
        checkButton.layer.borderColor = UIColor.systemGray4.cgColor
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
            checkButton.backgroundColor = .white
            checkButton.layer.borderWidth = 0
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkButton.tintColor = checkcolor
        } else {
            checkButton.backgroundColor = .clear
            checkButton.layer.borderWidth = 2
            checkButton.setImage(nil, for: .normal)
        }
    }
}



