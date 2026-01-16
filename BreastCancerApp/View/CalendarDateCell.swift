import UIKit

class CalendarDateCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!
    @IBOutlet weak var dotView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(day: String, isSelected: Bool, hasPlan: Bool, isFuture: Bool, isToday: Bool) {
        
        dayLabel.text = day
        dayLabel.textColor = .black
        dayLabel.isHidden = false
        dayLabel.alpha = 1.0
        
        selectionLayer.backgroundColor = .clear
        selectionLayer.isHidden = false
        
        if let dot = dotView {
            dot.isHidden = true
        }
        
      
        if day.isEmpty {
            dayLabel.text = ""
            return
        }
        
     
        if isFuture {
            dayLabel.textColor = UIColor.lightGray
            dayLabel.alpha = 0.5
            selectionLayer.backgroundColor = .clear
            dotView?.isHidden = true
            self.isUserInteractionEnabled = false
            return
        }
        
      
        self.isUserInteractionEnabled = true
        

        if isToday {
            
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
