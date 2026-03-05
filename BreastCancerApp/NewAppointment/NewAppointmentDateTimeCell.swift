//
//  NewAppointmentDateTimeCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/03/26.
//

import UIKit

class NewAppointmentDateTimeCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureAsDate(current: Date?) {
        titleLabel.text = "Date *"
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        if let d = current { datePicker.date = d }
    }

    func configureAsTime(current: Date?) {
        titleLabel.text = "Time *"
        datePicker.datePickerMode = .time
        if let d = current { datePicker.date = d }
    }
}
