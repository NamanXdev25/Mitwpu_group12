import UIKit

protocol GuidesCardCellDelegate: AnyObject {
    func guidesCardCellDidTapVideoGuide(_ cell: GuidesCardCell)
    func guidesCardCellDidTapAudioGuide(_ cell: GuidesCardCell)
}

final class GuidesCardCell: UICollectionViewCell {
    // MARK: - Card

    @IBOutlet private var cardView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var divider1: UIView!
    @IBOutlet private var divider2: UIView!

    // MARK: - Video Guide Row

    @IBOutlet private var videoRowView: UIView!
    @IBOutlet private var videoGuideLabel: UILabel!
    @IBOutlet private var videoChevronButton: UIButton!

    // MARK: - Audio Guide Row

    @IBOutlet private var audioRowView: UIView!

    @IBOutlet private var audioGuideLabel: UILabel!

    @IBOutlet private var audioChevronButton: UIButton!

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
