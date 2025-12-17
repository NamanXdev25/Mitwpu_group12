import UIKit

class VideoControlsCell: UICollectionViewCell {
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    var onPlayPause: (() -> Void)?
    var onRestart: (() -> Void)?
    var onLoop: ((Bool) -> Void)?
    var onSeek: ((Float) -> Void)?
    
    var isPlaying = false
    var isLooping = false
    var progressTimer: Timer?
    var currentSeconds: Int = 0
    var totalSeconds: Int = 240
    
    var isDragging = false
    var wasPlayingBeforeDrag = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateLoopButtonAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopProgressTimer()
        isLooping = false
        isDragging = false
        updateLoopButtonAppearance()
        resetPlayButton()
    }
    
    func updateLoopButtonAppearance() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let iconName = isLooping ? "repeat.1" : "repeat"
        replayButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        
        let color = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 1.0)
        replayButton.tintColor = color
    }
    
    func configure(currentTime: Int, totalTime: Int) {
        self.currentSeconds = currentTime
        self.totalSeconds = totalTime
        
        updateTimeLabels()
        updateProgress()
        
        // Ensure play button matches current state (optional, but good practice)
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .thin)
        let iconName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        playButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
    }
    
    func updateProgress() {
        if !isDragging {
            let progress = totalSeconds > 0 ? Float(currentSeconds) / Float(totalSeconds) : 0
            progressSlider.value = progress
        }
    }
    
    func updateTimeLabels() {
        currentTimeLabel.text = formatTime(currentSeconds)
        totalTimeLabel.text = formatTime(totalSeconds)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    func startProgressTimer() {
        stopProgressTimer()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.isDragging { return }
            
            if self.currentSeconds < self.totalSeconds {
                self.currentSeconds += 1
                self.updateProgress()
                self.updateTimeLabels()
            } else {
                if self.isLooping {
                    // Loop logic is handled by the PlayerCell notification,
                    // but we reset UI counter here to match
                    self.currentSeconds = 0
                    self.updateProgress()
                    self.updateTimeLabels()
                } else {
                    self.stopProgressTimer()
                    self.resetPlayButton()
                }
            }
        }
    }
    
    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    func resetPlayButton() {
        isPlaying = false
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .thin)
        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
    }
    
    @IBAction func restartTapped(_ sender: Any) {
        animateButton(restartButton)
        
        // 1. Reset Time
        currentSeconds = 0
        updateProgress()
        updateTimeLabels()
        
        // 2. FIX: Force UI to "Playing" state
        // Even if we were paused, restart implies "Play from start"
        isPlaying = true
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .thin)
        playButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: config), for: .normal)
        startProgressTimer()
        
        // 3. Notify Controller
        onRestart?()
    }
    
    @IBAction func playTapped(_ sender: Any) {
        isPlaying.toggle()
        
        let iconName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .thin)
        playButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        
        if isPlaying {
            startProgressTimer()
        } else {
            stopProgressTimer()
        }
        
        animateButton(playButton)
        onPlayPause?()
    }
    
    @IBAction func replayTapped(_ sender: Any) {
        animateButton(replayButton)
        
        isLooping.toggle()
        updateLoopButtonAppearance()
        
        let message = isLooping ? "Loop enabled 🔁" : "Loop disabled"
        onLoop?(isLooping)
        showLoopToast(message: message)
    }
    
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        isDragging = true
        wasPlayingBeforeDrag = isPlaying
        if isPlaying {
            stopProgressTimer()
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        currentSeconds = Int(sender.value * Float(totalSeconds))
        updateTimeLabels()
    }
    
    @IBAction func sliderTouchUp(_ sender: UISlider) {
        isDragging = false
        currentSeconds = Int(sender.value * Float(totalSeconds))
        updateTimeLabels()
        
        onSeek?(sender.value)
        
        if wasPlayingBeforeDrag {
            startProgressTimer()
        }
    }
    
    func showLoopToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = .systemFont(ofSize: 12, weight: .medium)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 0
        
        self.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            toastLabel.topAnchor.constraint(equalTo: replayButton.bottomAnchor, constant: 8),
            toastLabel.heightAnchor.constraint(equalToConstant: 28),
            toastLabel.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
}

