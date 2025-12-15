//
//  BreathingPlayerViewController.swift
//  BreastCancerApp
//
//  Created by Shloka on 14/12/25.
//

import UIKit
import AVKit
import AVFoundation

class BreathingPlayerViewController: UIViewController {

    var session: BreathingSession?
    
    // --- Outlets ---
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    // NEW: The Smart Timer View
    @IBOutlet weak var timerView: CircularTimerView!
    
    // --- Video Player Variables ---
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaying = false
    
    // --- Timer Logic ---
    var timer: Timer?
    var secondsRemaining = 0
    var totalSessionDuration = 0
    var isTimerRunning = false

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Create UI
        addTopGradient() // Pink Header
        
        // 2. Load Data
        setupData()
        prepareVideo()
        
        // 3. Layer Management
        // Video goes to back
        if let vContainer = videoContainerView {
            view.sendSubviewToBack(vContainer)
        }
        // Button goes to front
        if let pButton = playButton {
            view.bringSubviewToFront(pButton)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let vContainer = videoContainerView {
             playerLayer?.frame = vContainer.bounds
        }
    }
    
    // MARK: - Setup Functions
    
    func setupData() {
            guard let session = session else { return }
            
            self.title = session.title
            
            if let bgImageView = backgroundImageView {
                bgImageView.image = UIImage(named: session.imageName)
                
                // --- FORCE THE FIX HERE ---
                // This overrides Storyboard and guarantees the image looks normal (zoomed, not squashed)
                bgImageView.contentMode = .scaleAspectFill
                bgImageView.clipsToBounds = true
                // --------------------------
            }
            
            // PARSE DURATION
            let components = session.duration.components(separatedBy: " ")
            if let minutesString = components.first, let minutes = Int(minutesString) {
                totalSessionDuration = minutes * 60
            } else {
                totalSessionDuration = 600
            }
            
            secondsRemaining = totalSessionDuration
            
            if let tView = timerView {
                tView.updateProgress(secondsRemaining: secondsRemaining, totalDuration: totalSessionDuration)
            }
        }
    
    func prepareVideo() {
        guard let session = session else { return }
        
        var videoPath: String?
        if let path = Bundle.main.path(forResource: session.videoFileName, ofType: "mp4") { videoPath = path }
        else if let path = Bundle.main.path(forResource: session.videoFileName, ofType: "mov") { videoPath = path }
        
        guard let safePath = videoPath else { return }
        let url = URL(fileURLWithPath: safePath)
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let vContainer = videoContainerView {
            playerLayer?.frame = vContainer.bounds
            vContainer.layer.addSublayer(playerLayer!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    func addTopGradient() {
        let gradientOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 150))
        gradientOverlayView.backgroundColor = .clear
        gradientOverlayView.isUserInteractionEnabled = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientOverlayView.bounds
        
        let topColor = UIColor(red: 0.6, green: 0.2, blue: 0.3, alpha: 0.85).cgColor
        let bottomColor = UIColor.clear.cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        gradientOverlayView.layer.addSublayer(gradientLayer)
        view.addSubview(gradientOverlayView)
        view.bringSubviewToFront(gradientOverlayView)
    }
    
    // MARK: - Actions & Timer Logic
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if isPlaying {
            // PAUSE
            player?.pause()
            stopTimer()
            isPlaying = false
            
            let config = UIImage.SymbolConfiguration(pointSize: 80)
            playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
            
            UIView.animate(withDuration: 0.3) { self.backgroundImageView.alpha = 1 }
        } else {
            // PLAY
            player?.play()
            startTimer()
            isPlaying = true
            
            let config = UIImage.SymbolConfiguration(pointSize: 80)
            playButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: config), for: .normal)
            
            UIView.animate(withDuration: 0.5) { self.backgroundImageView.alpha = 0 }
        }
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        isTimerRunning = true
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    func tick() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            
            // NEW: Tell the view to update itself
            timerView.updateProgress(secondsRemaining: secondsRemaining, totalDuration: totalSessionDuration)
            
        } else {
            // Timer Finished
            stopTimer()
            player?.pause()
            isPlaying = false
            let config = UIImage.SymbolConfiguration(pointSize: 80)
            playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
            UIView.animate(withDuration: 0.3) { self.backgroundImageView.alpha = 1 }
            
            // Reset View
            timerView.reset()
        }
    }
    
    @objc func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    // MARK: - Navigation Bar Styling
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
}
