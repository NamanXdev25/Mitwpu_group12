//
// VideoGuideViewController.swift
//

import UIKit
import AVFoundation

class VideoGuideViewController: UIViewController {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var actualVideoView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var logSelfExamButton: UIButton!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    private var isSeeking = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    deinit {
        if let token = timeObserverToken { player?.removeTimeObserver(token) }
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player = nil
    }

    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "self_exam", withExtension: "mp4") else {
            print("Video not found in bundle: self_exam.mp4")
            return
        }
        player = AVPlayer(url: url)

        guard let player = player else { return }

        let pl = AVPlayerLayer(player: player)
        pl.videoGravity = .resizeAspect
        playerLayer = pl

        actualVideoView.layer.masksToBounds = true
        actualVideoView.clipsToBounds = true
        actualVideoView.layer.insertSublayer(pl, at: 0)

        pl.frame = actualVideoView.bounds
        pl.position = CGPoint(x: actualVideoView.bounds.midX, y: actualVideoView.bounds.midY)

        view.bringSubviewToFront(playPauseButton)
        view.bringSubviewToFront(progressSlider)
        view.bringSubviewToFront(logSelfExamButton)

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, !self.isSeeking,
                  let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
            self.progressSlider.value = Float(time.seconds / duration)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let pl = playerLayer else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        pl.frame = actualVideoView.bounds
        pl.position = CGPoint(x: actualVideoView.bounds.midX, y: actualVideoView.bounds.midY)
        CATransaction.commit()
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    @IBAction func progressChanged(_ sender: UISlider) {}

    @IBAction func progressTouchDown(_ sender: UISlider) {
        isSeeking = true
    }

    @IBAction func progressTouchUp(_ sender: UISlider) {
        guard let player = player, let duration = player.currentItem?.duration.seconds, duration > 0 else {
            isSeeking = false
            return
        }
        let seconds = Double(progressSlider.value) * duration
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time) { [weak self] _ in
            self?.isSeeking = false
        }
    }

    @objc private func didFinishPlaying() {
        player?.seek(to: .zero)
        player?.pause()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        progressSlider.value = 0
    }

    @IBAction func logSelfExamTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let obsVC = sb.instantiateViewController(withIdentifier: "ObservationsViewController")
        navigationController?.pushViewController(obsVC, animated: true)
    }
}
