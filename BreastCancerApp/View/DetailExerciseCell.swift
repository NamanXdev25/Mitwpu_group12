import UIKit

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

    @IBAction func chevronTapped(_ sender: UIButton) {
        delegate?.didTapChevron(on: self)
    }
}

