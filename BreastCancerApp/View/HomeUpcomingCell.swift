import UIKit

class HomeUpcomingCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    
    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with model: HomeUpcomingModel) {
            titleLabel.text = model.title
            doctorNameLabel.text = model.doctorName
            dateLabel.text = model.date
            timeLabel.text = model.time
        }
    
    
}
