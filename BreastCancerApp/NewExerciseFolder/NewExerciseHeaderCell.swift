import UIKit

class NewExerciseHeaderCell: UICollectionReusableView {
    @IBOutlet var planTitleLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var exerciseCountLabel: UILabel!

    func configure(with plan: NewExercisePlan) {
        planTitleLabel.text = plan.level
        durationLabel.text = plan.duration
        exerciseCountLabel.text = "\(plan.exerciseCount) exercises"
    }
}
