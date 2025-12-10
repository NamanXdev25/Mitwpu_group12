//
//  ExercisePlayerViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 09/12/25.
//

import UIKit
import AVKit
import AVFoundation

class ExercisePlayerViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var exerciseData: DetailExerciseItem?
    var videoPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var isPlaying = false
    var currentTime: Double = 0
    var totalDuration: Double = 240
    
    // 🎯 TEST DIFFERENT HEIGHTS HERE!
    // Try: 400, 450, 500, 550, 600
    var currentVideoHeight: CGFloat = 350 {
        didSet {
            VideoPlayerCell.videoHeight = currentVideoHeight
            collectionView?.reloadSections(IndexSet(integer: 0))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 🔧 SET YOUR TEST HEIGHT HERE!
        VideoPlayerCell.videoHeight = currentVideoHeight
        
        setupNavigationBar()
        setupCollectionView()
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.94, alpha: 1.0)
        
        // 🎮 ADD TEST BUTTON (Optional - for live testing)
       // addHeightTestButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer?.pause()
    }
    
    func setupNavigationBar() {
        self.title = "Exercises"
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(systemName: "calendar.badge.plus", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        let barItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barItem
    }
    
    // 🎮 OPTIONAL: Add test button to try different heights
    func addHeightTestButton() {
        let testButton = UIButton(type: .system)
        testButton.setTitle("📏 Test Height", for: .normal)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 8
        testButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(testButton)
        
        NSLayoutConstraint.activate([
            testButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.widthAnchor.constraint(equalToConstant: 140),
            testButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        testButton.addTarget(self, action: #selector(testNextHeight), for: .touchUpInside)
    }
    
    @objc func testNextHeight() {
        // Cycle through heights: 400 → 450 → 500 → 550 → 600 → 400
        let heights: [CGFloat] = [400, 450, 500, 550, 600]
        
        if let currentIndex = heights.firstIndex(of: currentVideoHeight) {
            let nextIndex = (currentIndex + 1) % heights.count
            currentVideoHeight = heights[nextIndex]
        } else {
            currentVideoHeight = 500
        }
        
        print("📏 New video height: \(currentVideoHeight)")
        
        // Show alert with current height
        let alert = UIAlertController(title: "Video Height", message: "Current: \(Int(currentVideoHeight))px", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func calendarButtonTapped() {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
            if let sheet = calendarVC.sheetPresentationController {
                sheet.prefersGrabberVisible = true
            }
            self.present(calendarVC, animated: true, completion: nil)
        }
    }
    
    func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        collectionView.register(UINib(nibName: "VideoPlayerCell", bundle: nil), forCellWithReuseIdentifier: "VideoPlayerCell")
        collectionView.register(UINib(nibName: "ExerciseInfoCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseInfoCell")
        collectionView.register(UINib(nibName: "VideoControlsCell", bundle: nil), forCellWithReuseIdentifier: "VideoControlsCell")
        collectionView.register(UINib(nibName: "ActionButtonsCell", bundle: nil), forCellWithReuseIdentifier: "ActionButtonsCell")
    }
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createVideoSection()
            case 1: return self.createInfoSection()
            case 2: return self.createControlsSection()
            case 3: return self.createButtonsSection()
            default: return nil
            }
        }
    }
    
    func createVideoSection() -> NSCollectionLayoutSection {
        // Calculate based on current video height + padding
        let totalHeight = VideoPlayerCell.videoHeight + 40 // 20 top + 20 bottom
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(totalHeight) // Use absolute height
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 45, bottom: 0, trailing: 45)
        
        return section
    }
    
    func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    func createControlsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(140)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    func createButtonsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(88)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0)
        
        return section
    }
}

extension ExercisePlayerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            // Video Player Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerCell
            cell.configure(imageName: exerciseData?.imageName ?? "girl_stretch")
            return cell
            
        case 1:
            // Exercise Info Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseInfoCell", for: indexPath) as! ExerciseInfoCell
            cell.configure(
                title: exerciseData?.title ?? "Wall Climb Stretch",
                description: "A gentle exercise to improve shoulder mobility and range of motion after surgery.",
                level: "Beginner"
            )
            return cell
            
        case 2:
            // Video Controls Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoControlsCell", for: indexPath) as! VideoControlsCell
            cell.configure(currentTime: 9, totalTime: 240)
            
            // ✅ CORRECT CALLBACKS
            cell.onPlayPause = { [weak self] in
                self?.togglePlayPause()
            }
            
            cell.onRestart = { [weak self] in
                self?.restartVideo()
            }
            
            // ✅ USE onLoop instead of onReplay
            cell.onLoop = { [weak self] isLooping in
                self?.toggleLoop(enabled: isLooping)
            }
            
            cell.onSeek = { [weak self] progress in
                self?.seekToProgress(progress)
            }
            
            return cell
            
        case 3:
            // Action Buttons Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionButtonsCell", for: indexPath) as! ActionButtonsCell
            
            // ✅ CORRECT CALLBACKS
            cell.onAddToPlan = { [weak self] in
                self?.addToPlan()
            }
            
            cell.onSetReminder = { [weak self] in
                self?.setReminder()
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    // MARK: - Action Methods
    
    func togglePlayPause() {
        print("▶️/⏸️ Play/Pause tapped")
        // Your video player logic here
    }
    
    func restartVideo() {
        print("⏮️ Restart tapped - Going to 0:00")
        // Reset video to beginning
    }
    
    func toggleLoop(enabled: Bool) {
        print("🔁 Loop \(enabled ? "enabled" : "disabled")")
        // Handle loop state
    }
    
    func seekToProgress(_ progress: Float) {
        let seconds = Int(progress * 240) // 240 = total duration
        print("⏩ Seeked to: \(seconds) seconds")
        // Seek video to position
    }
    
    func addToPlan() {
        print("➕ Add to Plan tapped")
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Added to Plan",
            message: "\(exerciseData?.title ?? "Exercise") has been added to your plan",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // TODO: Actually add to plan data
    }
    
    func setReminder() {
        print("⏰ Set Reminder tapped")
        
        // Show time picker or navigate to reminder screen
        let alert = UIAlertController(
            title: "Set Reminder",
            message: "Reminder feature coming soon!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // TODO: Implement reminder logic
    }
}
