
import UIKit

class JournalCalendarDateCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!
    @IBOutlet weak var dotView: UIView!
    
    private let primaryColor = UIColor(named: "PrimaryColor") ?? .label
    
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
        dotView.isHidden = true
        dayLabel.textColor = .black
    }
    
    func configure(
        day: String,
        hasJournal: Bool,
        isSelected: Bool,
        isToday: Bool,
        isFuture: Bool
    ) {
        dayLabel.text = day
        
        selectionLayer.backgroundColor = .clear
        dotView.isHidden = true
        
        guard !day.isEmpty else { return }
        
        if hasJournal {
            dotView.isHidden = false
            dotView.backgroundColor = UIColor(named: "PrimaryColor")
        }
        
        if isFuture {
            dayLabel.textColor = .tertiaryLabel
            contentView.alpha = 0.4
            contentView.backgroundColor = .clear
            dotView.isHidden = true
            return
        }

        contentView.alpha = 1.0

        if isToday {
            selectionLayer.backgroundColor =
            UIColor(named: "PrimaryColor")?.withAlphaComponent(1.0)
            
            dayLabel.textColor = .white
            dotView.backgroundColor = .white
        }
        
        if isSelected {
            selectionLayer.backgroundColor =
            UIColor(named: "PrimaryColor")?.withAlphaComponent(0.2)
            
            dayLabel.textColor = UIColor(named: "PrimaryColor")
        }
    }
}
