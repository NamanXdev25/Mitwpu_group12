import UIKit

protocol GuidesCardCellDelegate: AnyObject {
    func guidesCardCellDidTapVideoGuide(_ cell: GuidesCardCell)
    func guidesCardCellDidTapAudioGuide(_ cell: GuidesCardCell)
}

final class GuidesCardCell: UICollectionViewCell {

    // MARK: - Card
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var divider1: UIView!
    @IBOutlet private weak var divider2: UIView!

    // MARK: - Video Guide Row
    @IBOutlet private weak var videoRowView: UIView!
    @IBOutlet private weak var videoGuideLabel: UILabel!
    @IBOutlet private weak var videoChevronButton: UIButton!

    // MARK: - Audio Guide Row
    @IBOutlet private weak var audioRowView: UIView!
    
    @IBOutlet private weak var audioGuideLabel: UILabel!

    
    @IBOutlet private weak var audioChevronButton: UIButton!

    weak var delegate: GuidesCardCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGestures()
    }

    // MARK: - Setup

    private func setupUI() {
        // Buttons are visual only
        videoChevronButton.isUserInteractionEnabled = false
        audioChevronButton.isUserInteractionEnabled = false
    }

    private func setupGestures() {
        videoRowView.isUserInteractionEnabled = true
        audioRowView.isUserInteractionEnabled = true

        let videoTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(videoRowTapped)
        )

        let audioTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(audioRowTapped)
        )

        videoRowView.addGestureRecognizer(videoTapGesture)
        audioRowView.addGestureRecognizer(audioTapGesture)
    }

    // MARK: - Actions

    @objc private func videoRowTapped() {
        delegate?.guidesCardCellDidTapVideoGuide(self)
    }

    @objc private func audioRowTapped() {
        delegate?.guidesCardCellDidTapAudioGuide(self)
    }
}
