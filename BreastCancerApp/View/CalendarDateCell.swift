import UIKit

class CalendarDateCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
        func configure(day: String, status: String) {
        dayLabel.text = day
        
        // Reset
        selectionLayer.backgroundColor = .clear
        dayLabel.textColor = .black
        
        if day.isEmpty { return }
        
        switch status {
        case "selected":
            // Dark Pink
            selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.4, blue: 0.5, alpha: 1.0)
            dayLabel.textColor = .white
            
        case "completed":
            // Light Pink
            selectionLayer.backgroundColor = UIColor(red: 0.95, green: 0.85, blue: 0.88, alpha: 1.0)
            dayLabel.textColor = .black
            
        default:
            selectionLayer.backgroundColor = .clear
        }
    }
}
