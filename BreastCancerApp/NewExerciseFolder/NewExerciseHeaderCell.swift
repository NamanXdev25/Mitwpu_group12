//
//  NewExerciseHeaderCell.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/02/26.
//

import UIKit

class NewExerciseHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var planTitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var exerciseCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with plan: NewExercisePlan) {
        planTitleLabel.text = plan.level
        durationLabel.text = plan.duration
        exerciseCountLabel.text = "\(plan.exerciseCount) exercises"
    }
}
