import UIKit

class ActionButtonsCell: UICollectionViewCell {
    
    @IBOutlet weak var addToPlanButton: UIButton!
    
    var onAddToPlan: (() -> Void)?
    var onSetReminder: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func addToPlanTapped(_ sender: Any) {
        animateButton(addToPlanButton)
        onAddToPlan?()
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

    func setAdded(_ added: Bool) {
        if added {
            addToPlanButton.setTitle("Remove", for: .normal)
            addToPlanButton.backgroundColor = .white
            let pink = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 1.0)
            addToPlanButton.setTitleColor(pink, for: .normal)
            addToPlanButton.layer.borderWidth = 1
            addToPlanButton.layer.borderColor = pink.cgColor
        } else {
            let pinkColor = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 1.0)
            addToPlanButton.setTitle("Add to Plan", for: .normal)
            addToPlanButton.backgroundColor = pinkColor
            addToPlanButton.setTitleColor(.white, for: .normal)
            addToPlanButton.layer.borderWidth = 0
            addToPlanButton.layer.borderColor = nil
        }
    }
}
