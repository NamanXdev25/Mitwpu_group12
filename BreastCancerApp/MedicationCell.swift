//
//  MedicationCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 14/12/25.
//

import UIKit

class MedicationCell: UICollectionViewCell {
    static let identifier = "MedicationCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var radioButton: UIButton! // Changed to UIButton
    @IBOutlet weak var pillNameLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardDesign()
        
        // Circle styling for the button
        radioButton.layer.cornerRadius = 12
       // radioButton.layer.borderWidth = 1.5
       // radioButton.layer.borderColor = UIColor.systemGray4.cgColor
        radioButton.setTitle("", for: .normal) // Clear default text
    }
    
    // Merged Design Logic
    private func setupCardDesign() {
        containerView.layer.cornerRadius = 13
        containerView.backgroundColor = .white
        
       // containerView.layer.shadowColor = UIColor.black.cgColor
       // containerView.layer.shadowOpacity = 0.08
        //containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
       // containerView.layer.shadowRadius = 8
       // containerView.layer.masksToBounds = false
    }
}
