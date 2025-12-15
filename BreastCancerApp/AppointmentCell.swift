//
//  AppointmentCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 14/12/25.
//

import UIKit

class AppointmentCell: UICollectionViewCell {
    
    // 1. Missing Identifier
    static let identifier = "AppointmentCell"

    // Your exact outlets (Do not change these)
    @IBOutlet weak var AppointmentCellTitle: UILabel!
    @IBOutlet weak var AppointmentCellView: UIView!
    @IBOutlet weak var DoctorName: UILabel!
    @IBOutlet weak var Dateandyear: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet weak var clockImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Helper to set data cleanly from the View Controller
    func configure(title: String, doctor: String, date: String, time: String) {
        AppointmentCellTitle.text = title
        DoctorName.text = doctor
        Dateandyear.text = date
        Time.text = time
    }
    
}
