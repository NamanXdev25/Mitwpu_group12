//
//  SymptomLogCell.swift
//  symptomTracking
//
//  Created by Shivani Dinesh on 04/01/26.
//

import UIKit

class SymptomLogCell: UITableViewCell {

    @IBOutlet var symptomNameLabel: UILabel!
    @IBOutlet var severityLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with log: SymptomLog) {
        symptomNameLabel.text = log.symptomName
        
        let severityText = SymptomDataSource.shared.getSeverityText(for: log.severity)
        severityLabel.text = severityText
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: log.timestamp)
    }
    
}
