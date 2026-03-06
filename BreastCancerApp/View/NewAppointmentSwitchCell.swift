//
//  NewAppointmentSwitchCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/03/26.
//

import UIKit

class NewAppointmentSwitchCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!

    var onToggle: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(isOn: Bool) {
        reminderSwitch.isOn = isOn
    }

    @IBAction func switchToggled(_ sender: UISwitch) {
        onToggle?(sender.isOn)
    }
}
