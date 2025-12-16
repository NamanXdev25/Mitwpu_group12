import UIKit

class VideoPlayerCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var isMuted = false
    static var videoHeight: CGFloat = 550
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(imageName: String) {
        if let img = UIImage(named: imageName) {
            videoImageView.image = img
        } else {
            videoImageView.backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1.0)
        }
        
        timeLabel.text = "  0:09 / 4:00  "
        
        isMuted = false
        updateSpeakerIcon()
        
        
    }
    
    func updateSpeakerIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let iconName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        speakerButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
    }
    
    @IBAction func speakerTapped(_ sender: UIButton) {
        print("🔊 Speaker button tapped!")
        
        isMuted.toggle()
        updateSpeakerIcon()
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
