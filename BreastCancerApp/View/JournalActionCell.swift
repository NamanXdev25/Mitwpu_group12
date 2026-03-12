
import UIKit

class JournalActionCell: UICollectionViewCell {

    static let reuseIdentifier = "JournalActionCell"
    
    var didTap: (() -> Void)?
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String, subtitle: String, icon: UIImage) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            iconView.image = icon
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didTap?()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        didTap?()
    }
}
