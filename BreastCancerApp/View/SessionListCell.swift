import UIKit

// 1. The Protocol
protocol SessionCellDelegate: AnyObject {
    func didTapLikeButton(on cell: UICollectionViewCell)
}

class SessionListCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

    // 2. The Delegate Variable
    weak var delegate: SessionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.layer.masksToBounds = true
    }
    
    // 3. The Action for the Button
    // IMPORTANT: Connect this to your Button in the XIB!
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
