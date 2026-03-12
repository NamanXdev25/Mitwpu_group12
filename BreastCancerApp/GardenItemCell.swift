
import UIKit

class GardenItemCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemImageView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 9, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        
        separatorView.backgroundColor = UIColor.systemGray5
    }
    
    func configure(with item: StoreItem, isLast: Bool) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.name
        
        separatorView.isHidden = isLast
    }
}
