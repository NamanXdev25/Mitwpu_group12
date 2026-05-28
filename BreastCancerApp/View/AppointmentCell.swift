import UIKit

class AppointmentCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var noteLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

    func configure(with appointment: AppointmentItem) {
        titleLabel.text = appointment.title
        titleLabel.textColor = .black
        timeLabel.text = appointment.time

        let displayNote = appointment.noteBody
        if displayNote.isEmpty {
            noteLabel.text = "No Description"
            noteLabel.textColor = .lightGray
        } else {
            noteLabel.text = displayNote
            noteLabel.textColor = .darkGray
        }
    }
}
