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

    // Programmatically created empty state label
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

        // Add empty label to the white container view
        Appointmentconatiner.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: Appointmentconatiner.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: Appointmentconatiner.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: Appointmentconatiner.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: Appointmentconatiner.trailingAnchor, constant: -16)
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
