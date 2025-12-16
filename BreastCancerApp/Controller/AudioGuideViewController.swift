import UIKit
import AVFoundation

class AudioGuideViewController: UIViewController {

    //Outlets
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var back5Button: UIButton!
    @IBOutlet weak var forward5Button: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logSelfExamButton: UIButton!

    // MARK: - Private Properties
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    private let timerInterval: TimeInterval = 0.3
    private let seekInterval: TimeInterval = 5.0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioPlayer()
        updatePlayPauseButton()
    }

    // MARK: - Audio Setup
    private func setupAudioPlayer() {
        guard let audioURL = Bundle.main.url(forResource: "audio_guide", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            player = audioPlayer
            configureSlider(duration: audioPlayer.duration)
        } catch {
            print("Failed to load audio: \(error)")
        }
    }

    private func configureSlider(duration: TimeInterval) {
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(duration)
        progressSlider.value = 0
    }

    // MARK: - Timer Management
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: timerInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func updateProgress() {
        guard let player = player else { return }
        progressSlider.value = Float(player.currentTime)
        
        if !player.isPlaying {
            timer?.invalidate()
        }
    }
    
    // MARK: - UI Updates
    private func updatePlayPauseButton() {
        guard let player = player else { return }
        
      
        let imageName = player.isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        
    }

    // MARK: - Actions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else {
            print("Player not initialized")
            return
        }

        if player.isPlaying {
            player.pause()
            timer?.invalidate()
        } else {
            player.play()
            startTimer()
        }
        
        updatePlayPauseButton()
    }

    @IBAction func back5Tapped(_ sender: UIButton) {
        guard let player = player else { return }
        player.currentTime = max(0, player.currentTime - seekInterval)
        updateProgress()
    }

    @IBAction func forward5Tapped(_ sender: UIButton) {
        guard let player = player else { return }
        player.currentTime = min(player.duration, player.currentTime + seekInterval)
        updateProgress()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
        updateProgress()
    }

    @IBAction func logSelfExamTapped(_ sender: UIButton) {
        guard let observationsVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ObservationsViewController") as? UIViewController else {
            return
        }
        navigationController?.pushViewController(observationsVC, animated: true)
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioGuideViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        updatePlayPauseButton()
        progressSlider.value = 0
    }
}
