import UIKit

class SelfExamCardCell: UICollectionViewCell {
    @IBOutlet var cardView: UIView!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    private func setupViews() {
        cardView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
    }
}
