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
    
    func configure(name: String) {
        let firstName = name.components(separatedBy: " ").first ?? name
        greetingLabel.text = "Hello, \(firstName)!"
    }
    
    
    @IBAction func profileTapped(_ sender: UIButton) {
        print("Profile tapped!")
    }
    
    private func addBottomGradient() {
        gradientLayer?.removeFromSuperlayer()

        let gradient = CAGradientLayer()

        let baseColor = UIColor(named: "logsbgcolor") ?? .white

        gradient.colors = [
            baseColor.withAlphaComponent(0.0).cgColor,
            baseColor.withAlphaComponent(0.4).cgColor,
            baseColor.withAlphaComponent(0.9).cgColor
        ]

        gradient.locations = [0.0, 0.65, 1.0]

        contentView.layer.insertSublayer(gradient, above: backgroundImageView.layer)
        self.gradientLayer = gradient
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradientHeight: CGFloat = contentView.bounds.height + 50
        gradientLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width, 
            height: gradientHeight
        )
    }
}


