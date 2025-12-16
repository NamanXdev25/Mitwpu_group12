import UIKit
import AVKit
import AVFoundation

class BreathingPlayerViewController: UIViewController {

    var session: BreathingSession?
    // Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var videoContainerView: VideoPlayerContainerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timerView: CircularTimerView!
    
    //Video Player Variables
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaying = false
    var isFirstPlay = true
    
    //Timer Logic
    var timer: Timer?
    var secondsRemaining = 300 // 5 mins
    var totalSessionDuration = 300
    var isTimerRunning = false

    // MARK: - Navigation Bar Configuration
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // a Transparent Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        // Title set to WHITE
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        
        // Apply settings
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // Make Back Button White
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // restore the navigation bar to black title when leaving this screen
        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithDefaultBackground()
        
        defaultAppearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        
        // Apply default settings
        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
        navigationController?.navigationBar.compactAppearance = defaultAppearance
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        prepareVideo()
        setupTapGesture()
        timerView.reset()
    }

    // MARK: - Setup - binds model data to ui
    func setupData() {
        guard let session = session else { return }
        self.title = session.title
        
        if let bgImageView = backgroundImageView {
            bgImageView.image = UIImage(named: session.imageName)
        }
        // Fixed 5 minutes
        totalSessionDuration = 300
        secondsRemaining = totalSessionDuration
    }
    //MARK : - Sets up video playback sys  and media coordination
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
        
        videoContainerView.playerLayer = playerLayer

        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    func setupTapGesture() {
        //  allows tapping on the screen to pause
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tapGesture)
    }
      
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
            // pause
            player?.pause()
            stopTimer()
            isPlaying = false
            
            // Hide Timer txt
            timerView.setTimerTextHidden(true)
            
            // show Play Button
            playButton.isHidden = false
            showBackground()

        } else {
            // resume
            player?.play()
            startTimer()
            isPlaying = true
            
            // Show  Timer Text
            timerView.setTimerTextHidden(false)
            
            // hide Play Button
            playButton.isHidden = true
            hideBackground()
        }
    }
    
    //MARK: - Timer Engine
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
            //FINISHED LOGIC
            stopTimer()
            player?.pause()
            isPlaying = false
            
            //Ensure circle is full pink
            timerView.setFullProgress()
            
            //Show the "Peace" Message
            timerView.showMessage("A quiet bloom marks your moment of peace")
            
            //Keep Play Button HIDDEN so they can read the text
            playButton.isHidden = true
            UIView.animate(withDuration: 0.3) { self.backgroundImageView.alpha = 1 }
            
            //Wait 2 Seconds, THEN reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                
                //Reset UI for next time
                self.timerView.reset()
                self.isFirstPlay = true
                self.secondsRemaining = 300
                
                //Show Play Button now
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
    
    // MARK: - View State Updates
    func showBackground() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundImageView.alpha = 1
        }
    }
    func hideBackground() {
        UIView.animate(withDuration: 0.5) {
            self.backgroundImageView.alpha = 0
        }
    }
}
