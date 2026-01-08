//
//  SymptomLogCell2.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/01/26.
//

import UIKit

class SymptomLogCell: UICollectionViewCell {

    @IBOutlet var symptomNameLabel: UILabel!
    @IBOutlet var severityLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add styling for collection cell
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
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
