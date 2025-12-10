//
//  VideoPlayerCell.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 09/12/25.
//

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
        
        self.backgroundColor = .clear
        
        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 28
        containerView.clipsToBounds = true
        containerView.isUserInteractionEnabled = true
        
        // Image view
        videoImageView.contentMode = .scaleAspectFill
        videoImageView.clipsToBounds = true
        videoImageView.isUserInteractionEnabled = false
        
        // Speaker button - Will be made circular in layoutSubviews
        speakerButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        speakerButton.clipsToBounds = true
        speakerButton.isUserInteractionEnabled = true
        
        // IMPORTANT: Don't set corner radius here, do it in layoutSubviews
        
        containerView.bringSubviewToFront(speakerButton)
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        speakerButton.setImage(UIImage(systemName: "speaker.wave.2.fill", withConfiguration: config), for: .normal)
        speakerButton.tintColor = .darkGray
        
        // Time label
        timeLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        timeLabel.textColor = .white
        timeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        timeLabel.layer.cornerRadius = 16
        timeLabel.clipsToBounds = true
        timeLabel.textAlignment = .center
        timeLabel.isUserInteractionEnabled = false
        
        containerView.bringSubviewToFront(timeLabel)
        
        applyDynamicHeight()
    }
    
    func applyDynamicHeight() {
        if let heightConstraint = containerHeightConstraint {
            heightConstraint.constant = VideoPlayerCell.videoHeight
        }
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply corner radius after layout
        containerView.layer.cornerRadius = 28
        videoImageView.layer.cornerRadius = 28
        
        // 🔵 FIX: Make speaker button perfectly round
        // Use the actual frame size to ensure it's circular
        speakerButton.layer.cornerRadius = speakerButton.frame.width / 2
        
        // Ensure buttons are on top
        containerView.bringSubviewToFront(speakerButton)
        containerView.bringSubviewToFront(timeLabel)
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
        
        applyDynamicHeight()
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
