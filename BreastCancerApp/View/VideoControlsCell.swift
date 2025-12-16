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
    var currentSeconds: Int = 9
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
    }
    
  
    
    func updateLoopButtonAppearance() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let iconName = isLooping ? "repeat.1" : "repeat"
        replayButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        
        let color = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 1.0)
        replayButton.tintColor = color
        
        if isLooping {
           // replayButton.backgroundColor = UIColor(red: 0.95, green: 0.45, blue: 0.55, alpha: 0.15)
           // replayButton.layer.cornerRadius = 22
        } else {
            replayButton.backgroundColor = .clear
        }
    }
    

    
    func configure(currentTime: Int, totalTime: Int) {
        self.currentSeconds = currentTime
        self.totalSeconds = totalTime
        
        updateTimeLabels()
        updateProgress()
    }
    
    func updateProgress() {
      
        if !isDragging {
            let progress = Float(currentSeconds) / Float(totalSeconds)
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
            
            // Don't update if user is dragging
            if self.isDragging { return }
            
            if self.currentSeconds < self.totalSeconds {
                self.currentSeconds += 1
                self.updateProgress()
                self.updateTimeLabels()
            } else {
                if self.isLooping {
                    print("🔁 Looping video...")
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
        
        currentSeconds = 0
        updateProgress()
        updateTimeLabels()
        
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
        print(message)
        
        onLoop?(isLooping)
        showLoopToast(message: message)
    }
    
   
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        print("👆 User started dragging slider")
        isDragging = true
        wasPlayingBeforeDrag = isPlaying
        
        // Pause the timer while dragging
        if isPlaying {
            stopProgressTimer()
        }
    }
    
   
    @IBAction func sliderChanged(_ sender: UISlider) {
        // Update time display as user drags
        currentSeconds = Int(sender.value * Float(totalSeconds))
        updateTimeLabels()
        
        print("🎯 Slider at: \(formatTime(currentSeconds))")
    }
    
   
    @IBAction func sliderTouchUp(_ sender: UISlider) {
        print("✋ User finished dragging slider")
        isDragging = false
        
        // Update final position
        currentSeconds = Int(sender.value * Float(totalSeconds))
        updateTimeLabels()
        
        print("✅ Seeked to: \(formatTime(currentSeconds))")
        
        // Notify parent
        onSeek?(sender.value)
        
        // Resume playback if it was playing before
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
