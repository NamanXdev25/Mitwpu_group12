import UIKit

class CalendarDateCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView! // The big pink circle
    @IBOutlet weak var dotView: UIView!      // The small pink dot below the date

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(day: String, isSelected: Bool, hasPlan: Bool, isFuture: Bool, isToday: Bool) {
        // 1. RESET: Start with the state that worked in your initial code
        dayLabel.text = day
        dayLabel.textColor = .black
        dayLabel.isHidden = false
        dayLabel.alpha = 1.0
        
        selectionLayer.backgroundColor = .clear
        selectionLayer.isHidden = false
        
        if let dot = dotView {
            dot.isHidden = true
        }
        
        // 2. Early exit for empty padding squares
        if day.isEmpty {
            dayLabel.text = ""
            return
        }
        
        // 3. Handle future dates - gray them out and disable interaction
        if isFuture {
            dayLabel.textColor = UIColor.lightGray
            dayLabel.alpha = 0.5
            selectionLayer.backgroundColor = .clear
            dotView?.isHidden = true
            self.isUserInteractionEnabled = false
            return
        }
        
        // Re-enable interaction for non-future dates
        self.isUserInteractionEnabled = true
        
        // 4. APPLY LOGIC: Today should ALWAYS show dark pink, even when not selected
        if isToday {
            // Current date - ALWAYS show bright/dark pink circle
            selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
            dayLabel.textColor = .white
        } else if isSelected {
            // Past date selected - Light pink
            let lightpink = UIColor(named: "More_Exercise")
            selectionLayer.backgroundColor = lightpink
            dayLabel.textColor = .black
        } else if hasPlan {
            // Show small dot ONLY if not selected and not today
            dotView?.isHidden = false
        }
    }
}
