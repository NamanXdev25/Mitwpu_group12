import UIKit
protocol SessionCellDelegate: AnyObject {
    func didTapLikeButton(on cell: UICollectionViewCell)
}

class SessionListCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

   
    weak var delegate: SessionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(on: self)
    }

    func configureCell(session: BreathingSession) {
        titleLabel.text = session.title
        let clockIcon = "🕑"
        subtitleLabel.text = "\(session.category)  \(clockIcon) \(session.duration)"
        thumbnailImageView.image = UIImage(named: session.imageName)
        
        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)
        likeButton.tintColor = session.isFavorite ? .systemPink : .lightGray
    }
}
