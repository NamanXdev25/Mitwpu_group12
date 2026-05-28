import UIKit

class CareAppointmentsCell: UICollectionViewCell {
    @IBOutlet var Appointmentconatiner: UIView!
    @IBOutlet var AppointmentDateview: UIView!
    @IBOutlet var Appointmentmonthlabel: UILabel!
    @IBOutlet var AppointmentDatelabel: UILabel!
    @IBOutlet var AppointmentTitleLabel: UILabel!
    @IBOutlet var AppointmentDoctorLabel: UILabel!
    @IBOutlet var AppointmentClockImage: UIImageView!
    @IBOutlet var AppointmentTimeLabel: UILabel!

    private var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No appointments added"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        AppointmentDateview.layer.cornerRadius = 12

        Appointmentconatiner.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: Appointmentconatiner.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: Appointmentconatiner.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: Appointmentconatiner.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: Appointmentconatiner.trailingAnchor, constant: -16),
        ])
    }

    func configure(month: String, day: String, title: String, doctor: String, time: String) {
        let isEmpty = month == "---" || month.isEmpty

        AppointmentDateview.isHidden = isEmpty
        Appointmentmonthlabel.isHidden = isEmpty
        AppointmentDatelabel.isHidden = isEmpty
        AppointmentTitleLabel.isHidden = isEmpty
        AppointmentDoctorLabel.isHidden = isEmpty
        AppointmentClockImage.isHidden = isEmpty
        AppointmentTimeLabel.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty

        if !isEmpty {
            Appointmentmonthlabel.text = month
            AppointmentDatelabel.text = day
            AppointmentTitleLabel.text = title
            AppointmentDoctorLabel.text = doctor
            AppointmentTimeLabel.text = time
        }
    }
}
