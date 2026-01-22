import UIKit

class HomeHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var subGreetingLabel: UILabel!
    
    @IBOutlet weak var quoteLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?


    override func awakeFromNib() {
        super.awakeFromNib()
        addBottomGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.frame = backgroundImageView.bounds
    }

    private func addBottomGradient() {
        
        backgroundImageView.layer.mask = nil
        
        let mask = CAGradientLayer()
        
        mask.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        
        mask.locations = [0.0, 0.85, 1.0]
        
        mask.frame = backgroundImageView.bounds
        
        backgroundImageView.layer.mask = mask
        self.gradientLayer = mask
    }

    func configure(name: String) {
        let firstName = name.components(separatedBy: " ").first ?? name
        greetingLabel.text = "Hello, \(firstName)!"
    }
    
    
    @IBAction func profileTapped(_ sender: UIButton) {
        print("Profile tapped!")
    }
}


