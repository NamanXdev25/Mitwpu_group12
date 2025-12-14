import UIKit

class TrackingCell: UICollectionViewCell {
    static let identifier = "TrackingCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardDesign()
        setupChevronStyle()
    }
    
    // Merged Design Logic
    private func setupCardDesign() {
        containerView.layer.cornerRadius = 13
        containerView.backgroundColor = .white
        
    }
    
    private func setupChevronStyle() {
        // Exact styling to match StatsRowCell
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .small)
        let chevronImage = UIImage(systemName: "chevron.right", withConfiguration: config)
        
        // Apply to button
        chevronButton.setImage(chevronImage, for: .normal)
      //  chevronButton.tintColor = .black
        chevronButton.setTitle("", for: .normal)
    }
}
