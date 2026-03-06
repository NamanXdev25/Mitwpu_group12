//
//  NewAppointmentReminderTimeCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/03/26.

import UIKit

class NewAppointmentReminderTimeCell: UICollectionViewCell {

    @IBOutlet weak var addReminderButton: UIButton!

    var onAdd: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func addReminderTapped(_ sender: UIButton) {
        onAdd?()
    }
}
