//
//  MedicationItemCell.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class MedicationItemCell: UICollectionViewCell {

    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var pillNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @objc func circleTapped() {
        onCircleTapped?()
    }

    
    var onCircleTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(circleTapped))
        circleImageView.isUserInteractionEnabled = true
        circleImageView.addGestureRecognizer(tap)

    }

    func configureCell(with med: Medication) {
        pillNameLabel.text = med.name
        subtitleLabel.text = med.note
        timeLabel.text = med.time

        if med.isTaken {
            circleImageView.image = UIImage(systemName: "checkmark.circle.fill")
            circleImageView.tintColor = UIColor.systemBlue
        } else {
            circleImageView.image = UIImage(systemName: "circle")
            circleImageView.tintColor = UIColor.lightGray
        }
    }

}

