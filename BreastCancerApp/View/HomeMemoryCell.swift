import UIKit

class HomeMemoryCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var memoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with model: HomeMemoryModel) {
        memoryImageView.image = UIImage(named: model.imageName)
        titleLabel.text = model.date
        subtitleLabel.text = model.description
    }
}
