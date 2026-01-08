import UIKit

class CalendarDateCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView! // The big pink circle
    @IBOutlet weak var dotView: UIView!      // The small pink dot below the date

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        // Style the dot (small pink circle)
//        if let dot = dotView {
//            dot.layer.cornerRadius = dot.frame.width / 2
//            dot.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
//        }
//        
//        // Style the selection layer (large pink circle)
//        if let sel = selectionLayer {
//            // Ensure it's a circle. If your layer is 34x34, 17 is correct.
//            sel.layer.cornerRadius = sel.frame.width / 2
//            sel.clipsToBounds = true
//        }
    }
    
    func configure(day: String, isSelected: Bool, hasPlan: Bool) {
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
        
        // 3. APPLY LOGIC: Match the design requirements
        if isSelected {
            // Show big pink circle and white text
            selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
            dayLabel.textColor = .white
        } else if hasPlan {
            // Show small dot ONLY if not selected
            dotView?.isHidden = false
        }
        
//        // 4. HIERARCHY FIX:
//        // This ensures the label is physically drawn ON TOP of the pink circle
//        // even if the Storyboard order is wrong.
//        if let parent = dayLabel.superview {
//            parent.bringSubviewToFront(selectionLayer)
//            parent.bringSubviewToFront(dayLabel)
//        }
    }
}
