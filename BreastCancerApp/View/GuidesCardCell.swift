import UIKit

protocol GuidesCardCellDelegate: AnyObject {
    func guidesCellDidTapVideo(_ cell: GuidesCardCell)
    func guidesCellDidTapAudio(_ cell: GuidesCardCell)
}

class GuidesCardCell: UICollectionViewCell {

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
        contentView.backgroundColor = .clear
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        row1Label.font = .systemFont(ofSize: 16)
        row2Label.font = .systemFont(ofSize: 16)

        divider1.backgroundColor = UIColor(white: 0.9, alpha: 1)
        divider2.backgroundColor = UIColor(white: 0.9, alpha: 1)

        row1Chevron.image = UIImage(systemName: "chevron.right")
        row2Chevron.image = UIImage(systemName: "chevron.right")
        row1Chevron.tintColor = UIColor.systemBlue
        row2Chevron.tintColor = UIColor.systemBlue

        row1Chevron.isAccessibilityElement = false
        row2Chevron.isAccessibilityElement = false
        row1Label.accessibilityLabel = "Video Guide"
        row2Label.accessibilityLabel = "Audio Guide"

        // Make labels tappable
        row1Label.isUserInteractionEnabled = true
        row2Label.isUserInteractionEnabled = true
        row1Label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoTapped)))
        row2Label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(audioTapped)))
    }

    @objc private func videoTapped() { delegate?.guidesCellDidTapVideo(self) }
    @objc private func audioTapped() { delegate?.guidesCellDidTapAudio(self) }
}
