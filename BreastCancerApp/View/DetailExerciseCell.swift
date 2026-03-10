import UIKit

protocol DetailExerciseCellDelegate: AnyObject {
    func didTapChevron(on cell: DetailExerciseCell)
    func didTapRadioButton(on cell: DetailExerciseCell)
}

class DetailExerciseCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clockIconImageView: UIImageView!
    @IBOutlet weak var chevronButton: UIButton!

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
        // Only swap the SF Symbol — symbol scale (Medium) is set in the XIB.
        let symbolName = isCompleted ? "checkmark.circle.fill" : "circle"
        radioButton.configuration?.image = UIImage(systemName: symbolName)
        radioButton.tintColor = isCompleted
            ? UIColor(named: "primary_color")
            : UIColor.systemGray3
    }

    // MARK: - Actions
    @IBAction func radioButtonTapped(_ sender: UIButton) {
        delegate?.didTapRadioButton(on: self)
    }

    @IBAction func chevronTapped(_ sender: UIButton) {
        delegate?.didTapChevron(on: self)
    }
}
