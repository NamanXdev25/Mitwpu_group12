//
//  MedicationItemCell.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class MedicationItemCell: UICollectionViewCell {

    @IBOutlet weak var checkButton: UIButton!  // Changed from circleImageView to checkButton
    @IBOutlet weak var pillNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var onCircleTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup button appearance
        checkButton.layer.borderWidth = 2
        checkButton.layer.borderColor = UIColor.systemGray4.cgColor
        checkButton.layer.cornerRadius = checkButton.frame.width / 2  // Make it circular
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        onCircleTapped?()
    }

    func configureCell(with med: Medication) {
        pillNameLabel.text = med.name
        subtitleLabel.text = med.note
        timeLabel.text = med.time

        // Use your custom color or default to a pink color
        let checkColor = UIColor(named: "plusbuttoncolor") ?? UIColor(red: 0.85, green: 0.40, blue: 0.50, alpha: 1.0)
        
        if med.isTaken {
            // Completed state - filled with checkmark
            checkButton.backgroundColor = checkColor
            checkButton.layer.borderWidth = 0
            checkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkButton.tintColor = .white
        } else {
            // Uncompleted state - empty circle with border
            checkButton.backgroundColor = .clear
            checkButton.layer.borderWidth = 2
            checkButton.layer.borderColor = UIColor.systemGray4.cgColor
            checkButton.setImage(nil, for: .normal)
        }
    }
}
