import UIKit
import AVFoundation

final class AudioGuideViewController: UIViewController {

    @IBOutlet private weak var artworkImageView: UIImageView!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var back5Button: UIButton!
    @IBOutlet private weak var forward5Button: UIButton!
    @IBOutlet private weak var progressSlider: UISlider!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var logSelfExamButton: UIButton!

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?

    private let seekInterval: TimeInterval = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioPlayer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
    }

    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "audio_guide", withExtension: "mp3") else {
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            player = audioPlayer
            configureSlider(with: audioPlayer.duration)
        } catch {
            player = nil
        }
    }

    private func configureSlider(with duration: TimeInterval) {
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(duration)
        progressSlider.value = 0
    }

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func updateProgress() {
        guard let player = player else { return }

        progressSlider.value = Float(player.currentTime)

        if !player.isPlaying {
            progressTimer?.invalidate()
        }
    }

    @IBAction private func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
            startProgressTimer()
        }
    }

    @IBAction private func back5Tapped(_ sender: UIButton) {
        guard let player = player else { return }

        player.currentTime = max(0, player.currentTime - seekInterval)
        updateProgress()
    }

    @IBAction private func forward5Tapped(_ sender: UIButton) {
        guard let player = player else { return }

        player.currentTime = min(player.duration, player.currentTime + seekInterval)
        updateProgress()
    }

    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
        updateProgress()
    }

    @IBAction private func logSelfExamTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showObservations", sender: sender)
    }
}
