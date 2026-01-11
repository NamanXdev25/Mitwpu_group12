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
        // Remove all cell styling
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // Selection style
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Remove any spacing/insets
        contentView.frame = bounds
    }
    
    func configure(with appointment: AppointmentItem) {
        titleLabel.text = appointment.title
        titleLabel.textColor = .black
        timeLabel.text = appointment.time
        
        // Show note if available
        if appointment.note.isEmpty {
            noteLabel.text = "No Description"
            noteLabel.textColor = .lightGray
        } else {
            noteLabel.text = appointment.note
            noteLabel.textColor = .darkGray
        }
    }
}

