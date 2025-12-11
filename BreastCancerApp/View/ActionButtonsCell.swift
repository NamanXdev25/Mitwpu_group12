//
//  ActionButtonsCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 09/12/25.
//

import UIKit

class ActionButtonsCell: UICollectionViewCell {
    
    @IBOutlet weak var addToPlanButton: UIButton!
   // @IBOutlet weak var setReminderButton: UIButton!
    
    // ✅ THESE ARE THE CLOSURES
    var onAddToPlan: (() -> Void)?
    var onSetReminder: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        // Add to Plan - Pink filled button
        let pinkColor = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 1.0)
        addToPlanButton.backgroundColor = pinkColor
        addToPlanButton.setTitleColor(.white, for: .normal)
        addToPlanButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addToPlanButton.layer.cornerRadius = 28
        addToPlanButton.setTitle("Add to Plan", for: .normal)
        
        // Set Reminder - White with subtle border
      //  setReminderButton.backgroundColor = .white
        //setReminderButton.setTitleColor(.black, for: .normal)
       // setReminderButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
       // setReminderButton.layer.cornerRadius = 28
        //setReminderButton.layer.borderWidth = 1
      //  setReminderButton.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
       // setReminderButton.setTitle("Set Reminder", for: .normal)
    }
    
    // ✅ THESE ARE THE IBACTIONS
    @IBAction func addToPlanTapped(_ sender: Any) {
        animateButton(addToPlanButton)
        onAddToPlan?()  // Call the closure
    }
    
  //  @IBAction func setReminderTapped(_ sender: Any) {
       // animateButton(setReminderButton)
        // onSetReminder?()  // Call the closure
  //  }
    
    func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
}
