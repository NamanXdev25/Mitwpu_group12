import UIKit

class LogsAppointmentCell: UICollectionViewCell {

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
    
    func configure(with model: AppointmentModel) {
        AppointmentCellTitle.text = model.title
        DoctorName.text = model.doctorName
        Dateandyear.text = model.dateAndYear
        Time.text = model.time
    }
}
