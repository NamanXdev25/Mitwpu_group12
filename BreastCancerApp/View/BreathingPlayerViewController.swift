//
//  BreathingPlayerViewController.swift
//  BreastCancerApp
//
//  Created by Shloka on 09/12/25.
//

import UIKit
import AVKit
import AVFoundation

class BreathingPlayerViewController: UIViewController {

    var session: BreathingSession?
    
    // UI Outlets (Connect these in Storyboard!)
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var videoContainerView: UIView! // The clear view we added
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    // Video Player
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        prepareVideo() // Loads the video but pauses at start
        
        // Force the buttons to sit ON TOP of the video layer
                view.bringSubviewToFront(videoContainerView) // Ensure container is managed
                view.bringSubviewToFront(playButton)
                view.bringSubviewToFront(backButton)
                view.bringSubviewToFront(titleLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure video layer fits perfectly even if screen rotates
        playerLayer?.frame = videoContainerView.bounds
    }
    
    func setupData() {
        guard let session = session else { return }
        titleLabel.text = session.title
        backgroundImageView.image = UIImage(named: session.imageName)
    }
    
    func prepareVideo() {
        guard let session = session else { return }
        
        // Find Video File
        var videoPath: String?
        if let path = Bundle.main.path(forResource: session.videoFileName, ofType: "mp4") { videoPath = path }
        else if let path = Bundle.main.path(forResource: session.videoFileName, ofType: "mov") { videoPath = path }
        
        guard let safePath = videoPath else {
            print("Video not found: \(session.videoFileName)")
            return
        }
        
        let url = URL(fileURLWithPath: safePath)
        
        // Setup Player
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = videoContainerView.bounds
        
        // Add Video Layer to the Container View
        videoContainerView.layer.addSublayer(playerLayer!)
        
        // Loop Logic
        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    // MARK: - Actions
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            isPlaying = false
            
            // UI: Show Play Icon, Show Background
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
            
            UIView.animate(withDuration: 0.3) {
                self.backgroundImageView.alpha = 1
            }
        } else {
            player?.play()
            isPlaying = true
            
            // UI: Show Pause Icon, Hide Background
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            playButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: config), for: .normal)
            
            UIView.animate(withDuration: 0.5) {
                self.backgroundImageView.alpha = 0 // Reveal the video behind it
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        player?.pause()
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


