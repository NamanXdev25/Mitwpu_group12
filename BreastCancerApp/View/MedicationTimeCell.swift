//
//  MedicationTimeCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 20/03/26.
//

import UIKit

class MedicationTimeCell: UICollectionViewCell {
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var deleteButton: UIButton!

    var onDelete: (() -> Void)?
    var onTimeChange: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        timePicker.datePickerMode = .time
        timePicker.contentHorizontalAlignment = .left
        timePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
    }

    func configure(time: Date) {
        timePicker.date = time
    }

    @IBAction func deleteTapped(_: UIButton) {
        onDelete?()
    }

    @objc private func pickerChanged() {
        onTimeChange?(timePicker.date)
    }
}
