//
//  AppointmentCell.swift
//  Appointments
//
//  Created by Naman Bhansali on 11/01/26.
//

import UIKit

class AppointmentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
    
    func configure(with appointment: AppointmentItem) {
        // Show custom title if available, otherwise show category
        if !appointment.title.isEmpty {
            titleLabel.text = appointment.title
        } else {
            titleLabel.text = appointment.category
        }
        
        titleLabel.textColor = .black
        timeLabel.text = appointment.time
        
        if appointment.note.isEmpty {
            noteLabel.text = "No Description"
            noteLabel.textColor = .lightGray
        } else {
            noteLabel.text = appointment.note
            noteLabel.textColor = .darkGray
        }
    }
}
