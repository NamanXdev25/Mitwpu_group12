import UIKit

class ExerciseCalendarDateCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!
    @IBOutlet weak var dotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionLayer.layer.cornerRadius = selectionLayer.frame.height / 2
        selectionLayer.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionLayer.backgroundColor = .clear
        dotView?.isHidden = true
        dayLabel.textColor = .black
        contentView.alpha = 1.0
        isUserInteractionEnabled = true
    }
    
    func configure(day: String, isSelected: Bool, hasPlan: Bool, isFuture: Bool, isToday: Bool) {
        dayLabel.text = day
        dayLabel.textColor = .black
        
        selectionLayer.backgroundColor = .clear
        dotView?.isHidden = true
        
        guard !day.isEmpty else { return }
        
        // Future dates OR today - disabled (non-tappable)
        if isFuture || isToday {
            dayLabel.textColor = isToday ? .white : .lightGray
            contentView.alpha = isToday ? 1.0 : 0.5
            dotView?.isHidden = true
            isUserInteractionEnabled = false
            
            // Show today's special appearance
            if isToday {
                selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
                if hasPlan {
                    dotView?.isHidden = false
                    dotView?.backgroundColor = .white
                }
            }
            return
        }
        
        // Past dates - tappable
        contentView.alpha = 1.0
        isUserInteractionEnabled = true
        
        if isSelected {
            // Selected past date - light pink background
            selectionLayer.backgroundColor = UIColor(named: "More_Exercise")
            dayLabel.textColor = .black
            if hasPlan {
                dotView?.isHidden = false
                dotView?.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
            }
        } else if hasPlan {
            // Has plan but not selected - show dot only
            dotView?.isHidden = false
            dotView?.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
        }
    }
}
