import UIKit

protocol SessionCellDelegate: AnyObject {
    func didTapLikeButton(on cell: UICollectionViewCell)
}

class SessionListCell: UICollectionViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var likeButton: UIButton!

    weak var delegate: SessionCellDelegate?

    func configureCell(session: BreathingSession) {
        titleLabel.text = session.title
        durationLabel.text = session.duration
        thumbnailImageView.image = UIImage(named: session.imageName)

        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)
        likeButton.tintColor = session.isFavorite ? .systemPink : .lightGray
    }

    @IBAction func likeButtonTapped(_: UIButton) {
        delegate?.didTapLikeButton(on: self)
    }
}
