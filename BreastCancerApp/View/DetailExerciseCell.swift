import UIKit

protocol DetailExerciseCellDelegate: AnyObject {
    func didTapChevron(on cell: DetailExerciseCell)
    func didTapRadioButton(on cell: DetailExerciseCell)
}

class DetailExerciseCell: UICollectionViewCell {
    // MARK: - IBOutlets

    @IBOutlet var containerView: UIView!
    @IBOutlet var radioButton: UIButton!
    @IBOutlet var exerciseImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var clockIconImageView: UIImageView!
    @IBOutlet var chevronButton: UIButton!

    // MARK: - Delegate

    weak var delegate: DetailExerciseCellDelegate?

    // MARK: - State

    private(set) var isCompleted: Bool = false

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        updateRadioAppearance()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isCompleted = false
        updateRadioAppearance()
    }

    // MARK: - Configure

    func configure(title: String, subtitle: String, time: String, imageName: String, completed: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        timeLabel.text = time

        if let img = UIImage(named: imageName) {
            exerciseImageView.image = img
        } else {
            exerciseImageView.image = nil
            exerciseImageView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.08)
        }

        isCompleted = completed
        updateRadioAppearance()
    }

    // MARK: - Radio Button

    func setCompleted(_ completed: Bool) {
        isCompleted = completed
        updateRadioAppearance()
    }

    private func updateRadioAppearance() {
        let symbolName = isCompleted ? "checkmark.circle.fill" : "circle"
        radioButton.configuration?.image = UIImage(systemName: symbolName)
        radioButton.tintColor = isCompleted
            ? UIColor(named: "primary_color")
            : UIColor.systemGray3
    }

    // MARK: - Actions

    @IBAction func radioButtonTapped(_: UIButton) {
        delegate?.didTapRadioButton(on: self)
    }

    @IBAction func chevronTapped(_: UIButton) {
        delegate?.didTapChevron(on: self)
    }
}
