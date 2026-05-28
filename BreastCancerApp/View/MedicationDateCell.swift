import UIKit

class MedicationDateCell: UICollectionViewCell {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var selectionLayer: UIView!
    @IBOutlet var dotView: UIView!

    func configure(day: String, isSelected: Bool, hasMedications: Bool, isFuture: Bool, isToday: Bool) {
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
            isUserInteractionEnabled = false
            return
        }

        isUserInteractionEnabled = true

        if isToday {
            selectionLayer.backgroundColor = UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
            dayLabel.textColor = .white
        } else if isSelected {
            let lightpink = UIColor(red: 0.98, green: 0.89, blue: 0.92, alpha: 1.0)
            selectionLayer.backgroundColor = lightpink
            dayLabel.textColor = .black
        } else if hasMedications {
            dotView?.isHidden = false
        }
    }
}
