import UIKit

// Global delegate protocol so controllers can adopt it easily
protocol DetailExerciseCellDelegate: AnyObject {
    func didTapChevron(on cell: DetailExerciseCell)
}

class DetailExerciseCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clockIconImageView: UIImageView!
    @IBOutlet weak var chevronButton: UIButton!

    // MARK: - Delegate
    weak var delegate: DetailExerciseCellDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        /*
        // 1. Card Style
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = .white

        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6

        // 2. Image Style
        exerciseImageView.layer.cornerRadius = 10
        exerciseImageView.contentMode = .scaleAspectFill
        exerciseImageView.clipsToBounds = true

        // 3. Text Style
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.textColor = .darkGray
        subtitleLabel.font = .systemFont(ofSize: 13)

        timeLabel.textColor = .gray
        timeLabel.font = .systemFont(ofSize: 13)

        // 4. Icons
        clockIconImageView.tintColor = .systemGray
        clockIconImageView.image = UIImage(systemName: "clock")

        // 5. Chevron
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        chevronButton.tintColor = .systemGray3

        // Ensure button action exists (IBAction should be connected in IB; this is a safety)
        chevronButton.removeTarget(nil, action: nil, for: .allEvents)
        chevronButton.addTarget(self, action: #selector(chevronTapped(_:)), for: .touchUpInside)
         */
    }

    // MARK: - Configure
    func configure(title: String, subtitle: String, time: String, imageName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        timeLabel.text = time

        if let img = UIImage(named: imageName) {
            exerciseImageView.image = img
        } else {
            exerciseImageView.image = nil
            exerciseImageView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.08)
        }
    }

    // MARK: - IBAction
    // Connect this IBAction from the chevron UIButton in Interface Builder,
    // or the programmatic target above will also call it.
    @IBAction func chevronTapped(_ sender: UIButton) {
        delegate?.didTapChevron(on: self)
    }
}

