
import UIKit
import AVFoundation
import CoreMedia

final class BreathingPlayerViewController: UIViewController, AVAudioPlayerDelegate {

    var session: BreathingSession?

    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var videoContainerView: VideoPlayerContainerView?
    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var timerView: CircularTimerView?

    private var videoQueuePlayer: AVQueuePlayer?
    private var videoLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    private var audioPlayer: AVAudioPlayer?

    private var isPlaying = false
    private var isFirstPlay = true

    private var timer: Timer?
    private var secondsRemaining: Int = 0
    private var totalSessionDuration: Int = 0
    private var isTimerRunning = false

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithDefaultBackground()
        defaultAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]

        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
        navigationController?.navigationBar.compactAppearance = defaultAppearance

        stopAllPlayback()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let container = videoContainerView {
            playerLayer?.frame = container.bounds
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAVAudioSession()
        setupData()
        prepareLoopingVideoAndAudio()
        setupTapGesture()
        timerView?.reset()
    }

    deinit {
        stopTimer()
    }

    // MARK: - Setup
    private func configureAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
    }

    private func setupData() {
        guard let session else { return }
        title = ""
        backgroundImageView?.image = UIImage(named: session.imageName)
    }

    private func prepareLoopingVideoAndAudio() {
        guard let session else { return }
        guard let media = BreathingMediaCatalog.media(for: session.title) else {
            return
        }

        prepareLoopingVideo(
            videoName: media.videoName,
            loopStartTrim: media.loopStartTrim,
            loopEndTrim: media.loopEndTrim
        )
        prepareAudio(audioName: media.audioName)

        timerView?.reset()
        timerView?.updateProgress(
            secondsRemaining: secondsRemaining,
            totalDuration: max(totalSessionDuration, 1)
        )
    }

    private func prepareLoopingVideo(
        videoName: String,
        loopStartTrim: Double,
        loopEndTrim: Double
    ) {
        Task { [weak self] in
            guard let self = self else { return }
            guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
                return
            }

            let asset = AVURLAsset(url: url)
            guard let duration = try? await asset.load(.duration) else { return }
            let timescale: CMTimeScale = max(duration.timescale, 600)

            let start = CMTime(seconds: max(0, loopStartTrim), preferredTimescale: timescale)
            let endTrim = CMTime(seconds: max(0, loopEndTrim), preferredTimescale: timescale)
            let end = CMTimeSubtract(duration, endTrim)

            guard end > start else {
                return
            }

            let clipRange = CMTimeRange(start: start, end: end)
            let composition = AVMutableComposition()

            guard
                let tracks = try? await asset.loadTracks(withMediaType: .video),
                let srcTrack = tracks.first,
                let compTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                )
            else {
                return
            }

            do {
                try compTrack.insertTimeRange(clipRange, of: srcTrack, at: .zero)
                if let transform = try? await srcTrack.load(.preferredTransform) {
                    compTrack.preferredTransform = transform
                }
            } catch {
                return
            }

            let item = AVPlayerItem(asset: composition)
            item.seekingWaitsForVideoCompositionRendering = false

            let queue = AVQueuePlayer()
            queue.actionAtItemEnd = .none
            queue.isMuted = true
            queue.automaticallyWaitsToMinimizeStalling = false

            let loopRange = CMTimeRange(start: .zero, duration: clipRange.duration)
            let looper = AVPlayerLooper(player: queue, templateItem: item, timeRange: loopRange)

            await MainActor.run {
                guard let videoContainerView = self.videoContainerView else {
                    return
                }

                let layer = AVPlayerLayer(player: queue)
                layer.videoGravity = .resizeAspectFill
                layer.needsDisplayOnBoundsChange = true

                videoContainerView.playerLayer = nil
                videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

                layer.frame = videoContainerView.bounds
                videoContainerView.layer.addSublayer(layer)

                self.videoQueuePlayer = queue
                self.videoLooper = looper
                self.playerLayer = layer
            }
        }
    }

    private func prepareAudio(audioName: String) {
        let supportedExtensions = ["mp3", "m4a", "wav", "aac", "mpeg"]
        var foundURL: URL?

        for ext in supportedExtensions {
            if let url = Bundle.main.url(forResource: audioName, withExtension: ext) {
                foundURL = url
                break
            }
        }

        guard let audioURL = foundURL else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.delegate = self
            player.prepareToPlay()
            audioPlayer = player

            totalSessionDuration = max(Int(player.duration.rounded()), 1)
            secondsRemaining = totalSessionDuration
        } catch {
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func screenTapped() {
        if !isFirstPlay {
            togglePlayPause()
        }
    }

    // MARK: - Actions
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if isFirstPlay {
            startBreathingSequence()
        } else {
            togglePlayPause()
        }
    }

    private func startBreathingSequence() {
        guard audioPlayer != nil else {
            return
        }

        isFirstPlay = false
        isPlaying = true

        playButton?.isHidden = true
        timerView?.showMessage("Take a deep breath in")

        videoQueuePlayer?.play()
        audioPlayer?.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.startTimer()
        }

        hideBackground()
    }

    private func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
            videoQueuePlayer?.pause()
            stopTimer()
            isPlaying = false

            timerView?.setTimerTextHidden(true)
            playButton?.isHidden = false
            showBackground()
        } else {
            audioPlayer?.play()
            videoQueuePlayer?.play()
            startTimer()
            isPlaying = true

            timerView?.setTimerTextHidden(false)
            playButton?.isHidden = true
            hideBackground()
        }
    }

    // MARK: - Timer Engine
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        isTimerRunning = true
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    private func tick() {
        guard let audioPlayer else { return }

        let current = Int(audioPlayer.currentTime.rounded())
        let total = max(totalSessionDuration, 1)
        secondsRemaining = max(total - current, 0)

        timerView?.updateProgress(secondsRemaining: secondsRemaining, totalDuration: total)

        if secondsRemaining <= 0 || !audioPlayer.isPlaying {
            handleSessionFinished()
        }
    }

    private func handleSessionFinished() {
        stopTimer()
        audioPlayer?.pause()
        videoQueuePlayer?.pause()
        isPlaying = false

        timerView?.setFullProgress()
        timerView?.showMessage("A quiet bloom marks your moment of peace")

        CoinRewardService.shared.awardBreathingCoinsIfEligible(on: self)

        playButton?.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.backgroundImageView?.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }

            self.timerView?.reset()
            self.isFirstPlay = true
            self.secondsRemaining = self.totalSessionDuration

            self.audioPlayer?.currentTime = 0
            self.videoQueuePlayer?.seek(to: .zero)

            self.playButton?.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            self.playButton?.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        }
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        handleSessionFinished()
    }

    // MARK: - UI Helpers
    private func showBackground() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundImageView?.alpha = 1
        }
    }

    private func hideBackground() {
        UIView.animate(withDuration: 0.5) {
            self.backgroundImageView?.alpha = 0
        }
    }

    private func stopAllPlayback() {
        stopTimer()
        audioPlayer?.pause()
        videoQueuePlayer?.pause()
    }
}
