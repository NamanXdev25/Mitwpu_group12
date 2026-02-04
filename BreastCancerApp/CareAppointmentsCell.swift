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
        // Style the date badge (the pink square on the left)
        AppointmentDateview.layer.cornerRadius = 12
    }

    func configure(month: String, day: String, title: String, doctor: String, time: String) {
        Appointmentmonthlabel.text = month
        AppointmentDatelabel.text = day
        AppointmentTitleLabel.text = title
        AppointmentDoctorLabel.text = doctor
        AppointmentTimeLabel.text = time
    }
}
