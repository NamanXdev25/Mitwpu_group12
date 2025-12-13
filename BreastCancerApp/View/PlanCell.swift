//
//  PlanCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 26/11/25.
//

import UIKit

class PlanCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView!
  //  @IBOutlet weak var chevronButton: UIButton!
    
    // --- NEW OUTLET ---
    @IBOutlet weak var clockIcon: UIImageView!
    
    var onToggle: (() -> Void)?
    var onNavigate: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Basic Style
        containerView.backgroundColor = .white
        containerView.layer.shadowOpacity = 0
        
        // 2. Check Button Style
        checkButton.layer.cornerRadius = 15
        checkButton.layer.borderWidth = 2
        checkButton.layer.borderColor = UIColor.systemGray4.cgColor
        checkButton.setTitle("", for: .normal)
        
        // 3. Clock Icon Style
        clockIcon.tintColor = .systemGray
        clockIcon.contentMode = .scaleAspectFit
        
        // 4. Chevron Style
        //let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
       // chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        //chevronButton.tintColor = .systemGray3
    }

    @IBAction func checkButtonTapped(_ sender: Any) {
        onToggle?()
    }
    
    //@IBAction func chevronTapped(_ sender: Any) {
       // onNavigate?()
   // }
    
    func configure(with item: PlanItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        timeLabel.text = item.time
        
        if item.isCompleted {
            checkButton.backgroundColor = .systemPink
            checkButton.layer.borderWidth = 0
            checkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkButton.tintColor = .white
        } else {
            checkButton.backgroundColor = .clear
            checkButton.layer.borderWidth = 2
            checkButton.setImage(nil, for: .normal)
        }
    }
}



