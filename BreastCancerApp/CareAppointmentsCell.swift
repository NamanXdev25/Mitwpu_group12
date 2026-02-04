//
//  CareAppointmentsCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 04/02/26.
//

import UIKit

class CareAppointmentsCell: UICollectionViewCell {

    @IBOutlet weak var Appointmentconatiner: UIView!
    
    @IBOutlet weak var AppointmentDateview: UIView!
    
    @IBOutlet weak var Appointmentmonthlabel: UILabel!
    
    
    @IBOutlet weak var AppointmentDatelabel: UILabel!
    
    @IBOutlet weak var AppointmentTitleLabel: UILabel!
    
    
    @IBOutlet weak var AppointmentDoctorLabel: UILabel!
    
    @IBOutlet weak var AppointmentClockImage: UIImageView!
    
    
    @IBOutlet weak var AppointmentTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
