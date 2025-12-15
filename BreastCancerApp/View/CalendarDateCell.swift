import UIKit

class CalendarDateCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Default style
        selectionLayer.backgroundColor = .clear
        dayLabel.textColor = .black
    }
    
    // --- FIX FOR PERFECT CIRCLES ---
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 1. Ensure the view is a circle (Width / 2)
        // If your constraint in Storyboard is 30x30, this will be 15.
        // If it stretches, this ensures it stays round.
        selectionLayer.layer.cornerRadius = selectionLayer.frame.height / 2
        selectionLayer.layer.masksToBounds = true
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
