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

    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        onCircleTapped?()
    }

    func configureCell(with med: Medication) {
        pillNameLabel.text = med.name
        subtitleLabel.text = med.note
        timeLabel.text = med.time

        let checkColor = UIColor(named: "MedicationPrimaryColor")
        
        if med.isTaken {
            checkButton.backgroundColor = checkColor
            checkButton.layer.borderWidth = 0
            checkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkButton.tintColor = .white
        } else {
            checkButton.backgroundColor = .clear
            checkButton.layer.borderWidth = 2
            checkButton.layer.borderColor = UIColor.systemGray4.cgColor
            checkButton.setImage(nil, for: .normal)
        }
    }
}
