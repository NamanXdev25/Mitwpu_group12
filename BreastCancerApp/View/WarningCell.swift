import UIKit

class WarningCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Container Layout
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        
        // --- Background Color ---
        if let bgColor = UIColor(named: "WarningColor") {
            containerView.backgroundColor = bgColor
        } else {
            containerView.backgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.90, alpha: 1.0) // Cream Fallback
        }
        
        // --- Border Color (SEPARATE) ---
        if let borderColor = UIColor(named: "WarningBorderColor") {
            containerView.layer.borderColor = borderColor.cgColor
        } else {
            // Gold Fallback
            containerView.layer.borderColor = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0).cgColor
        }
        
        // --- Icon Color ---
        if let iconColor = UIColor(named: "WarningIconColor") {
            warningIcon.tintColor = iconColor
        } else {
            // Gold Fallback
            warningIcon.tintColor = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
        }
        
        // --- Text Color ---
        if let textColor = UIColor(named: "WarningTextColor") {
            warningLabel.textColor = textColor
        } else {
            // Dark Brown Fallback
            warningLabel.textColor = UIColor(red: 0.60, green: 0.40, blue: 0.00, alpha: 1.0)
        }
    }
    
    func setup(message: String) {
        warningLabel.text = message
    }
}
