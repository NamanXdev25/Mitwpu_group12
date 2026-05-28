import UIKit

class HomeMemoryCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var memoryImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    func configure(with model: HomeMemoryModel) {
        memoryImageView.image = UIImage(named: model.imageName)
        titleLabel.text = model.date
        subtitleLabel.text = model.description
    }
}

extension HomeMemoryCell {
    func configureWithMemory(_ memory: Memory) {
        if let image = memory.image {
            memoryImageView?.image = image
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        titleLabel?.text = formatter.string(from: memory.date)

        subtitleLabel?.text = memory.note ?? "Memory"
    }
}
