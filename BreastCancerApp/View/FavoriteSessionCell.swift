import UIKit
// Note: The 'SessionCellDelegate' protocol is already defined in SessionListCell.swift,
// so we don't need to define it again. Swift can see it!

class FavoriteSessionCell: UICollectionViewCell {

    // OUTLETS
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var heartContainerView: UIView!

    // 1. Add Delegate Variable
    weak var delegate: SessionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    // 2. Add Action for the Heart Button
    // IMPORTANT: You must connect this in the XIB!
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(on: self)
    }

    func configureCell(session: BreathingSession) {
        titleLabel.text = session.title
        categoryLabel.text = session.category
        sessionImageView.image = UIImage(named: session.imageName)
        
        let heartName = session.isFavorite ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartName), for: .normal)
        likeButton.tintColor = .systemPink
    }
}
