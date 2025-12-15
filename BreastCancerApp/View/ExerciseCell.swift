import UIKit

class ExerciseCell: UICollectionViewCell {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var nameButton: UIButton!

    var onNameButtonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        nameButton.backgroundColor = .white.withAlphaComponent(0.9)
        nameButton.setTitleColor(.black, for: .normal)
        
        // --- TEXT LAYOUT CONFIGURATION ---
        nameButton.titleLabel?.numberOfLines = 2
        nameButton.titleLabel?.lineBreakMode = .byWordWrapping
        nameButton.titleLabel?.textAlignment = .center
        nameButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        
        // Ensure button content is centered
        nameButton.contentHorizontalAlignment = .center
        nameButton.contentVerticalAlignment = .center
        
        // Add internal padding so text doesn't hit the pill edges
        nameButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        
        nameButton.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameButton.layer.cornerRadius = nameButton.bounds.height / 2
    }
    
    @IBAction func nameButtonAction(_ sender: Any) {
        onNameButtonTapped?()
    }

    func setup(title: String, image: UIImage?) {
        nameButton.setTitle(title, for: .normal)
        if let img = image {
            bgImageView.image = img
            bgImageView.contentMode = .scaleAspectFill
        } else {
            bgImageView.backgroundColor = .systemPink.withAlphaComponent(0.1)
        }
    }
}
