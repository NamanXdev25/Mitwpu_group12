//
//  MissedExerciseCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 07/01/26.
//

import UIKit

class MissedExerciseCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func configure(with item: PlanItem) {
        titleLabel.text = item.title
        timeLabel.text = item.time
    }
}
