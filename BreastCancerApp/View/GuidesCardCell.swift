import UIKit

protocol GuidesCardCellDelegate: AnyObject {
    func guidesCellDidTapVideo(_ cell: GuidesCardCell)
    func guidesCellDidTapAudio(_ cell: GuidesCardCell)
}

class GuidesCardCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider1: UIView!
    @IBOutlet weak var row1Label: UILabel!
    @IBOutlet weak var divider2: UIView!
    @IBOutlet weak var row2Label: UILabel!
    @IBOutlet weak var row1Chevron: UIImageView!
    @IBOutlet weak var row2Chevron: UIImageView!

    weak var delegate: GuidesCardCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureGestures()
    }

    // MARK: - Gesture Setup
    private func configureGestures() {
        row1Label.isUserInteractionEnabled = true
        row2Label.isUserInteractionEnabled = true

        row1Label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoTapped)))
        row2Label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(audioTapped)))
    }

    // MARK: - Actions
    @objc private func videoTapped() { delegate?.guidesCellDidTapVideo(self) }
    @objc private func audioTapped() { delegate?.guidesCellDidTapAudio(self) }
}
