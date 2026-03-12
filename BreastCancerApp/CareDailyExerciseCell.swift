import UIKit

// MARK: - Protocol
protocol CareDailyExerciseCellDelegate: AnyObject {
    func careDailyExerciseCellDidTapBegin(_ cell: CareDailyExerciseCell)
}

final class CareDailyExerciseCell: UICollectionViewCell {

    @IBOutlet weak var ExerciseContainer: UIView!
    @IBOutlet weak var ExerciseImage: UIImageView!
    @IBOutlet weak var ExerciseTitle: UILabel!
    @IBOutlet weak var ExerciseBeginButton: UIButton!

    @IBOutlet weak var ExerciseEmptyStateLabel: UILabel?

    weak var delegate: CareDailyExerciseCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        ExerciseBeginButton.addTarget(self, action: #selector(handleBeginTap), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ExerciseTitle.text = nil
        ExerciseImage.image = nil
        ExerciseEmptyStateLabel?.text = nil
        applyPlanState(hasPlan: true)
    }

    func configure(title: String, image: UIImage?, hasPlan: Bool) {
        applyPlanState(hasPlan: hasPlan)

        if hasPlan {
            ExerciseTitle.text = title
            ExerciseImage.image = image
            ExerciseEmptyStateLabel?.text = nil
        } else {
            let emptyText = "No plan added yet."
            if let emptyLabel = ExerciseEmptyStateLabel {
                emptyLabel.text = emptyText
            } else {
                ExerciseTitle.text = emptyText
            }
            ExerciseImage.image = nil
        }
    }

    @objc private func handleBeginTap() {
        delegate?.careDailyExerciseCellDidTapBegin(self)
    }

    private func applyPlanState(hasPlan: Bool) {
        ExerciseImage.isHidden = !hasPlan
        ExerciseBeginButton.isHidden = !hasPlan
        ExerciseBeginButton.isEnabled = hasPlan

        if ExerciseEmptyStateLabel != nil {
            ExerciseTitle.isHidden = !hasPlan
            ExerciseEmptyStateLabel?.isHidden = hasPlan
        } else {
            ExerciseTitle.isHidden = false
        }
    }
}
