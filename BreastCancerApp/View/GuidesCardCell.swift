import UIKit

protocol GuidesCardCellDelegate: AnyObject {
    func guidesCellDidTapVideo(_ cell: GuidesCardCell)
    func guidesCellDidTapAudio(_ cell: GuidesCardCell)
}

final class GuidesCardCell: UICollectionViewCell {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var divider1: UIView!
    @IBOutlet private weak var row1Label: UILabel!
    @IBOutlet private weak var divider2: UIView!
    @IBOutlet private weak var row2Label: UILabel!
    @IBOutlet private weak var row1Chevron: UIImageView!
    @IBOutlet private weak var row2Chevron: UIImageView!

    weak var delegate: GuidesCardCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureGestures()
    }

    private func configureGestures() {
        row1Label.isUserInteractionEnabled = true
        row2Label.isUserInteractionEnabled = true

        row1Label.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(videoTapped)
            )
        )

        row2Label.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(audioTapped)
            )
        )
    }

    @objc private func videoTapped() {
        delegate?.guidesCellDidTapVideo(self)
    }

    @objc private func audioTapped() {
        delegate?.guidesCellDidTapAudio(self)
    }
}
