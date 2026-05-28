import AVFoundation
import UIKit

final class VideoGuideViewController: UIViewController {
    @IBOutlet private var videoContainerView: UIView!
    @IBOutlet private var actualVideoView: UIView!
    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var progressSlider: UISlider!
    @IBOutlet private var logSelfExamButton: UIButton!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    private var isSeeking = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetPlayerToStart()
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }

        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player = nil
    }

    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "self_exam", withExtension: "mp4") else {
            return
        }

        let player = AVPlayer(url: url)
        self.player = player

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        playerLayer = layer

        actualVideoView.layer.masksToBounds = true
        actualVideoView.layer.insertSublayer(layer, at: 0)

        let interval = CMTime(
            seconds: 0.25,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )

        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard
                let self,
                !self.isSeeking,
                let duration = player.currentItem?.duration.seconds,
                duration > 0
            else { return }

            self.progressSlider.value = Float(time.seconds / duration)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = actualVideoView.bounds
    }

    private func resetPlayerToStart() {
        guard let player else { return }

        player.pause()
        player.seek(to: .zero)
        progressSlider.value = 0
        playPauseButton.setImage(
            UIImage(systemName: "play.fill"),
            for: .normal
        )
    }

    // MARK: - Play / Pause

    @IBAction private func playPauseTapped(_: UIButton) {
        guard let player else { return }

        if player.timeControlStatus == .playing {
            player.pause()
            playPauseButton.setImage(
                UIImage(systemName: "play.fill"),
                for: .normal
            )
        } else {
            player.play()
            playPauseButton.setImage(
                UIImage(systemName: "pause.fill"),
                for: .normal
            )
        }
    }

    // MARK: - Slider Scrubbing

    @IBAction private func progressTouchDown(_: UISlider) {
        isSeeking = true
        player?.pause()
    }

    @IBAction private func progressValueChanged(_ sender: UISlider) {
        guard
            let player,
            let duration = player.currentItem?.duration.seconds,
            duration > 0
        else { return }

        let seconds = Double(sender.value) * duration
        let time = CMTime(
            seconds: seconds,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )

        player.seek(
            to: time,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    @IBAction private func progressTouchUp(_ sender: UISlider) {
        guard
            let player,
            let duration = player.currentItem?.duration.seconds,
            duration > 0
        else {
            isSeeking = false
            return
        }

        let seconds = Double(sender.value) * duration
        let time = CMTime(
            seconds: seconds,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )

        player.seek(
            to: time,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        ) { [weak self] _ in
            self?.isSeeking = false
        }
    }

    @objc private func didFinishPlaying() {
        resetPlayerToStart()
    }

    @IBAction private func logSelfExamTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showObservations", sender: sender)
    }
}
