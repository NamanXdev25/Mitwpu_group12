import UIKit

class ActionButtonsCell: UICollectionViewCell {
    
    @IBOutlet weak var addToPlanButton: UIButton!
    
    // ✅ THESE ARE THE CLOSURES
    var onAddToPlan: (() -> Void)?
    var onSetReminder: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // ✅ THESE ARE THE IBACTIONS
    @IBAction func addToPlanTapped(_ sender: Any) {
        animateButton(addToPlanButton)
        onAddToPlan?()  // Call the closure
    }
    
    
    func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }

    // MARK: - Appearance Toggle
    func setAdded(_ added: Bool) {
        if added {
            // Show "Remove" style: white bg + pink border + pink text
            addToPlanButton.setTitle("Remove", for: .normal)
            addToPlanButton.backgroundColor = .white
            let pink = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 1.0)
            addToPlanButton.setTitleColor(pink, for: .normal)
            addToPlanButton.layer.borderWidth = 1
            addToPlanButton.layer.borderColor = pink.cgColor
        } else {
            // Restore "Add to Plan" pink filled look
            let pinkColor = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 1.0)
            addToPlanButton.setTitle("Add to Plan", for: .normal)
            addToPlanButton.backgroundColor = pinkColor
            addToPlanButton.setTitleColor(.white, for: .normal)
            addToPlanButton.layer.borderWidth = 0
            addToPlanButton.layer.borderColor = nil
        }
    }
}
