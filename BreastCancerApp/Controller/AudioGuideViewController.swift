import UIKit
import AVFoundation

class AudioGuideViewController: UIViewController {

    // UI connections
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var back5Button: UIButton!
    @IBOutlet weak var forward5Button: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logSelfExamButton: UIButton!

    // Audio engine
    private var player: AVAudioPlayer?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = titleLabel.text
        loadAudio()
    }

    // Load bundled audio file
    private func loadAudio() {
        guard let url = Bundle.main.url(forResource: "audio_guide", withExtension: "mp3"),
              let p = try? AVAudioPlayer(contentsOf: url) else { return }
        player = p
        p.prepareToPlay()
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(p.duration)
    }

    // Update slider as audio plays
    private func tick() {
        guard let p = player else { return }
        progressSlider.value = Float(p.currentTime)
        if !p.isPlaying { timer?.invalidate() }
    }

    // Toggle play/pause
    // Toggle play/pause
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let p = player else {
            print("PLAYER NIL")
            return
        }

        if p.isPlaying {
            p.pause()
            print("PAUSED")
        } else {
            p.play()
            startTimer()
            print("PLAYING")
        }
    }



    // Start periodic UI updates
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in self.tick() }
    }

    // Seek backward 5s
    @IBAction func back5Tapped(_ sender: UIButton) {
        guard let p = player else { return }
        p.currentTime = max(0, p.currentTime - 5)
        tick()
    }

    // Seek forward 5s
    @IBAction func forward5Tapped(_ sender: UIButton) {
        guard let p = player else { return }
        p.currentTime = min(p.duration, p.currentTime + 5)
        tick()
    }

    // Manual slider scrub
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
        tick()
    }

    // Navigate to Observations screen
    @IBAction func logSelfExamTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ObservationsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}
