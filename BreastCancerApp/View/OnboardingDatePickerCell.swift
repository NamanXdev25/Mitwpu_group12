//
//  OnboardingDatePickerCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 01/03/26.
//

import UIKit

class OnboardingDatePickerCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    var onDateChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    func configure(title: String, fieldName: String, maximumDate: Date? = Date()) {
        titleLabel.text        = title
        placeholderLabel.text  = fieldName
        datePicker.maximumDate = maximumDate
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
}
