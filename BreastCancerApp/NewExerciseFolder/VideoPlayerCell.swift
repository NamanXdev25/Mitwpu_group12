import UIKit
import AVKit

class VideoPlayerCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!

    // MARK: - Public State
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isMuted = false

    // MARK: - Target Duration
    var targetDuration: Double = 0

    var onDurationChanged: ((Double) -> Void)?
    var onPlaybackFinished: (() -> Void)?

    // MARK: - Private
    private var durationObserver: NSKeyValueObservation?
    private var targetTimer: Timer?
    private var elapsedSeconds: Double = 0
    private var clipDuration: Double = 0
    private var isLooping = false

    static var videoHeight: CGFloat = 350

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layoutIfNeeded()
        playerLayer?.frame = containerView.bounds
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        stopTargetTimer()
        NotificationCenter.default.removeObserver(self)
        durationObserver?.invalidate()
        durationObserver = nil
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        isLooping = false
        elapsedSeconds = 0
        clipDuration = 0
        targetDuration = 0
    }

    // MARK: - Configure
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
            print("VideoPlayerCell: video file not found for '\(videoName)'")
            return
        }

        let url = URL(fileURLWithPath: validPath)
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        containerView.layer.insertSublayer(playerLayer!, above: videoImageView.layer)
        containerView.layoutIfNeeded()
        playerLayer?.frame = containerView.bounds

        player?.isMuted = isMuted
        updateSpeakerIcon()

        let target = self.targetDuration

        durationObserver = playerItem.observe(\.duration, options: [.new, .initial]) { [weak self] item, _ in
            guard let self else { return }
            let time = item.duration
            guard time.isNumeric else { return }
            let seconds = CMTimeGetSeconds(time)
            guard seconds > 0, self.clipDuration == 0 else { return }
            self.clipDuration = seconds

            DispatchQueue.main.async {
                let reported = target > 0 ? target : seconds
                self.onDurationChanged?(reported)
                self.startLoopingPlayback(target: target)
            }
        }
    }

    // MARK: - Internal Playback

    private func startLoopingPlayback(target: Double) {
        elapsedSeconds = 0
        isLooping = true
        player?.play()
        videoImageView.isHidden = true

        if target > 0 {
            startTargetTimer(target: target)
        }
    }

    private func startTargetTimer(target: Double) {
        stopTargetTimer()
        targetTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 0.5
            if self.elapsedSeconds >= target {
                self.stopTargetTimer()
                self.isLooping = false
                self.player?.pause()
                self.onPlaybackFinished?()
            }
        }
    }

    private func stopTargetTimer() {
        targetTimer?.invalidate()
        targetTimer = nil
    }

    @objc private func playerItemDidReachEnd(notification: NSNotification) {
        guard isLooping else { return }
        player?.seek(to: .zero)
        player?.play()
    }

    // MARK: - Playback Controls

    func play() {
        isLooping = true
        player?.play()
        videoImageView.isHidden = true
        let remaining = targetDuration - elapsedSeconds
        if targetDuration > 0 && remaining > 0 {
            startTargetTimer(target: targetDuration)
        }
    }

    func pause() {
        player?.pause()
        stopTargetTimer()
    }

    func seek(to seconds: Double) {
        guard clipDuration > 0 else { return }
        let clipPosition = seconds.truncatingRemainder(dividingBy: clipDuration)
        let time = CMTime(seconds: clipPosition, preferredTimescale: 600)
        player?.seek(to: time)
        elapsedSeconds = seconds
    }

    // MARK: - Mute

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
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) { sender.transform = .identity }
        }
    }
}
