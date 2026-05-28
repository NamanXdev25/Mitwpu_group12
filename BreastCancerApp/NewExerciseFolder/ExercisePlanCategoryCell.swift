import UIKit

class ExercisePlanCategoryCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

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
