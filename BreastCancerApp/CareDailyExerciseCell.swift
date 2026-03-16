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
    private let generatedEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No plan added yet"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        ExerciseBeginButton.addTarget(self, action: #selector(handleBeginTap), for: .touchUpInside)

        if ExerciseEmptyStateLabel == nil {
            ExerciseContainer.addSubview(generatedEmptyLabel)
            NSLayoutConstraint.activate([
                generatedEmptyLabel.centerXAnchor.constraint(equalTo: ExerciseContainer.centerXAnchor),
                generatedEmptyLabel.centerYAnchor.constraint(equalTo: ExerciseContainer.centerYAnchor),
                generatedEmptyLabel.leadingAnchor.constraint(equalTo: ExerciseContainer.leadingAnchor, constant: 16),
                generatedEmptyLabel.trailingAnchor.constraint(equalTo: ExerciseContainer.trailingAnchor, constant: -16)
            ])
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ExerciseTitle.text = nil
        ExerciseImage.image = nil
        activeEmptyLabel().text = nil
        applyPlanState(hasPlan: true)
    }

    func configure(title: String, image: UIImage?, hasPlan: Bool) {
        applyPlanState(hasPlan: hasPlan)

        if hasPlan {
            ExerciseTitle.text = title
            ExerciseImage.image = image
            activeEmptyLabel().text = nil
        } else {
            activeEmptyLabel().text = "No plan added yet"
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
        ExerciseTitle.isHidden = !hasPlan
        activeEmptyLabel().isHidden = hasPlan
    }

    private func activeEmptyLabel() -> UILabel {
        ExerciseEmptyStateLabel ?? generatedEmptyLabel
    }
}
