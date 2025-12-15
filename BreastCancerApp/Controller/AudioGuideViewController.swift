import UIKit
import AVFoundation

class AudioGuideViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var back5Button: UIButton!
    @IBOutlet weak var forward5Button: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logSelfExamButton: UIButton!

    // MARK: - Audio
    private var player: AVAudioPlayer?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Audio Guide"
        titleLabel.text = "Audio Guide"

        setupAudio()
    }

    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "audio_guide", withExtension: "mp3") else {
            print("ERROR: audio file not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            progressSlider.minimumValue = 0
            progressSlider.maximumValue = Float(player?.duration ?? 0)
        } catch {
            print("ERROR loading audio:", error)
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.updateUI()
        }
    }

    private func updateUI() {
        guard let p = player else { return }
        progressSlider.value = Float(p.currentTime)

        if !p.isPlaying {
            timer?.invalidate()
        }
    }

    // MARK: - Actions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let p = player else { return }

        if p.isPlaying {
            p.pause()
        } else {
            p.play()
            startTimer()
        }
    }

    @IBAction func back5Tapped(_ sender: UIButton) {
        guard let p = player else { return }
        p.currentTime = max(0, p.currentTime - 5)
        updateUI()
    }

    @IBAction func forward5Tapped(_ sender: UIButton) {
        guard let p = player else { return }
        p.currentTime = min(p.duration, p.currentTime + 5)
        updateUI()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
        updateUI()
    }

    @IBAction func logSelfExamTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        // try two common IDs, fallback to a helpful log
        if let obs = sb.instantiateViewController(withIdentifier: "ObservationsViewController") as? ObservationsViewController {
            navigationController?.pushViewController(obs, animated: true)
            return
        }
        if let obs = sb.instantiateViewController(withIdentifier: "ObservationsVC") as? ObservationsViewController {
            navigationController?.pushViewController(obs, animated: true)
            return
        }
        assertionFailure("Observations VC storyboard ID not found. Set ID to ObservationsViewController in Main.storyboard.")
    }

}
