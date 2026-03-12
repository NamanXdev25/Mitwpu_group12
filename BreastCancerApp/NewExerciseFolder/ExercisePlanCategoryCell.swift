
import UIKit

class ExercisePlanCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with category: ExercisePlanCategory) {
        titleLabel.text = category.title
        subtitleLabel.text = category.subtitle
        
        if let imageName = category.headerImageName {
            imageView.image = UIImage(named: imageName)
        } else {
            imageView.image = nil
        }
    }
}
