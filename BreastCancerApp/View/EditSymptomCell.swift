//
//  EditSymptomCell.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class EditSymptomCell: UITableViewCell {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var symptomNameLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    var onActionTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        showsReorderControl = true
    }
    
    func configure(with symptom: Symptom, isInUserList: Bool) {
        symptomNameLabel.text = symptom.name
        
        if isInUserList {
            actionButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            actionButton.tintColor = .systemRed
        } else {
            actionButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            actionButton.tintColor = .systemGreen
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        onActionTapped?()
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        onInfoTapped?()
    }
}
