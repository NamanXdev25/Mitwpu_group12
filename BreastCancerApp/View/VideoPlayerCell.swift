import UIKit
import AVKit

class VideoPlayerCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var speakerButton: UIButton!

    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isMuted = false
    
   
    var isLooping = false
    
    var onDurationChanged: ((Double) -> Void)?
    private var durationObserver: NSKeyValueObservation?
    
    static var videoHeight: CGFloat = 350
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = containerView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       
        NotificationCenter.default.removeObserver(self)
        durationObserver?.invalidate()
        durationObserver = nil
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        isLooping = false
    }
    
    func configure(videoName: String, imageName: String) {
        if let img = UIImage(named: imageName) {
            videoImageView.image = img
            videoImageView.isHidden = false
        }
        
        var path = Bundle.main.path(forResource: videoName, ofType: "mp4")
        if path == nil {
            path = Bundle.main.path(forResource: videoName, ofType: "mov")
        }
        
        guard let validPath = path else {
            print("Video file not found: \(videoName)")
            return
        }
        
        let url = URL(fileURLWithPath: validPath)
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        player = AVPlayer(playerItem: playerItem)
        
      
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = containerView.bounds
        
        containerView.layer.insertSublayer(playerLayer!, above: videoImageView.layer)
        
        player?.isMuted = isMuted
        updateSpeakerIcon()
        
        durationObserver = playerItem.observe(\.duration, options: [.new, .initial]) { [weak self] item, change in
            let time = item.duration
            if time.isNumeric {
                let seconds = CMTimeGetSeconds(time)
                self?.onDurationChanged?(seconds)
            }
        }
    }
    
  
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        if isLooping {
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    func play() {
        player?.play()
        videoImageView.isHidden = true
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    func toggleMute() {
        isMuted.toggle()
        player?.isMuted = isMuted
        updateSpeakerIcon()
    }
    
    func updateSpeakerIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let iconName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        speakerButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
    }
    
    @IBAction func speakerTapped(_ sender: UIButton) {
        toggleMute()
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
    }
}
