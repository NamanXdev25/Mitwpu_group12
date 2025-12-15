import UIKit
import AVKit
import AVFoundation

class BreathingPlayerViewController: UIViewController {

    var session: BreathingSession?
    
    // --- Outlets ---
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timerView: CircularTimerView!
    
    // --- Video Player Variables ---
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaying = false
    var isFirstPlay = true
    
    // --- Timer Logic ---
    var timer: Timer?
    var secondsRemaining = 300 // 5 mins
    var totalSessionDuration = 300
    var isTimerRunning = false

    // MARK: - 🛑 Navigation Bar Configuration 🛑
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Create a Transparent Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // This removes the white box
        appearance.backgroundColor = .clear             // Ensures it is clear
        appearance.shadowColor = .clear                 // Removes the grey line
        
        // 2. Set Title to WHITE
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        
        // 3. Apply settings
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 4. Make Back Button White
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // RESTORE the navigation bar to default (black title) when leaving this screen
        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithDefaultBackground()
        
        // Set Title to BLACK
        defaultAppearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        
        // Apply default settings
        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
        navigationController?.navigationBar.compactAppearance = defaultAppearance
        
        // Restore default tint color (usually blue or your app's accent color)
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // 1. UI Setup
//        addTopGradient()
        
        // 2. Data Setup
        setupData()
        prepareVideo()
        setupTapGesture()
        
//        // 3. Layer Management
//        if let vContainer = videoContainerView {
//            view.sendSubviewToBack(vContainer)
//        }
//        if let bgImage = backgroundImageView {
//            view.sendSubviewToBack(bgImage)
//        }
//        if let pButton = playButton {
//            view.bringSubviewToFront(pButton)
//        }
        
        timerView.reset()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let vContainer = videoContainerView {
             playerLayer?.frame = vContainer.bounds
        }
    }
    
    // MARK: - Setup
    func setupData() {
        guard let session = session else { return }
        self.title = session.title
        
        if let bgImageView = backgroundImageView {
            bgImageView.image = UIImage(named: session.imageName)
            bgImageView.contentMode = .scaleAspectFill
            bgImageView.clipsToBounds = true
        }
        
        // Fixed 5 minutes
        totalSessionDuration = 300
        secondsRemaining = totalSessionDuration
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
    
    func setupTapGesture() {
        // This allows tapping anywhere on the screen (including the circle) to toggle pause
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
//    func addTopGradient() {
//        let gradientOverlay = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 150))
//        gradientOverlay.isUserInteractionEnabled = false
//        let gradient = CAGradientLayer()
//        gradient.frame = gradientOverlay.bounds
//        gradient.colors = [UIColor(red: 0.6, green: 0.2, blue: 0.3, alpha: 0.85).cgColor, UIColor.clear.cgColor]
//        gradientOverlay.layer.addSublayer(gradient)
//        view.addSubview(gradientOverlay)
//    }
//    
    // MARK: - Interaction Logic
    
    @objc func screenTapped() {
        if !isFirstPlay {
            togglePlayPause()
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if isFirstPlay {
            startBreathingSequence()
        } else {
            togglePlayPause()
        }
    }
    
    func startBreathingSequence() {
        isFirstPlay = false
        isPlaying = true
        
        // Hide Button immediately
        playButton.isHidden = true
        
        // Show Message
        timerView.showMessage("Take a deep breath in...")
        
        player?.play()
        
        // Wait 2 Seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.startTimer()
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            // PAUSE
            player?.pause()
            stopTimer()
            isPlaying = false
            
            // 1. Hide the Timer Text
            timerView.setTimerTextHidden(true)
            
            // 2. SHOW Play Button
            playButton.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
            
            UIView.animate(withDuration: 0.3) { self.backgroundImageView.alpha = 1 }
        } else {
            // RESUME
            player?.play()
            startTimer()
            isPlaying = true
            
            // 1. Show the Timer Text
            timerView.setTimerTextHidden(false)
            
            // 2. HIDE Play Button
            playButton.isHidden = true
            
            UIView.animate(withDuration: 0.5) { self.backgroundImageView.alpha = 0 }
        }
    }
    
    // MARK: - Timer Engine
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
            timerView.updateProgress(secondsRemaining: secondsRemaining, totalDuration: totalSessionDuration)
        } else {
            // --- FINISHED LOGIC ---
            stopTimer()
            player?.pause()
            isPlaying = false
            
            // 1. Ensure circle is full pink
            timerView.setFullProgress()
            
            // 2. Show the "Peace" Message
            timerView.showMessage("A quiet bloom marks your moment of peace")
            
            // 3. Keep Play Button HIDDEN so they can read the text
            playButton.isHidden = true
            UIView.animate(withDuration: 0.3) { self.backgroundImageView.alpha = 1 }
            
            // 4. Wait 2 Seconds, THEN reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                
                // Reset UI for next time
                self.timerView.reset()
                self.isFirstPlay = true
                self.secondsRemaining = 300
                
                // Show Play Button now
                self.playButton.isHidden = false
                let config = UIImage.SymbolConfiguration(pointSize: 60)
                self.playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
            }
        }
    }
    
    @objc func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }
}
