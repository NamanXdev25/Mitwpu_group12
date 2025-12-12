//
//  ExercisePlayerViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 09/12/25.
//

import UIKit
import AVKit
import AVFoundation

class ExercisePlayerViewController: UIViewController, AddExerciseDelegate {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload the buttons section to reflect latest plan membership
        collectionView.reloadSections(IndexSet(integer: 3))
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
    
    // MARK: - AddExerciseDelegate
    func didAddExercise(_ exercise: PlanItem) {
        // Add to shared model
        ExerciseManager.shared.addPlanItem(exercise)
        
        // Refresh the Buttons section so button text toggles
        collectionView.reloadSections(IndexSet(integer: 3))
        
        // Show toast
        showToast(message: "Exercise added to plan")
    }
    
    // Lightweight toast
    func showToast(message: String, duration: TimeInterval = 1.2) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textAlignment = .center
        toastLabel.alpha = 0
        toastLabel.numberOfLines = 0

        // Style
        toastLabel.backgroundColor = UIColor(white: 0.12, alpha: 0.88)
        toastLabel.textColor = .white
        toastLabel.layer.cornerRadius = 14
        toastLabel.layer.masksToBounds = true

        // Size & add
        let padding: CGFloat = 16
        let maxWidth = view.bounds.width - 60
        let targetSize = CGSize(width: maxWidth - padding*2, height: CGFloat.greatestFiniteMagnitude)
        var labelSize = toastLabel.sizeThatFits(targetSize)
        labelSize.width += padding*2
        labelSize.height += 12

        toastLabel.frame = CGRect(x: (view.bounds.width - labelSize.width)/2,
                                  y: view.bounds.height - (labelSize.height + 140),
                                  width: labelSize.width,
                                  height: labelSize.height)
        toastLabel.alpha = 0.0
        view.addSubview(toastLabel)

        // Animate in/out
        UIView.animate(withDuration: 0.18, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.18, delay: duration, options: [], animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
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
            // Action Buttons Cell - UPDATED LOGIC (ID-based)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionButtonsCell", for: indexPath) as! ActionButtonsCell
            
            // Determine if already present (use shared model & id)
            let alreadyAdded = (exerciseData != nil) ? ExerciseManager.shared.containsExercise(id: exerciseData!.id) : false
            cell.setAdded(alreadyAdded)
            
            // Callbacks
            cell.onAddToPlan = { [weak self] in
                guard let self = self, let detail = self.exerciseData else { return }
                
                if ExerciseManager.shared.containsExercise(id: detail.id) {
                    // Currently present -> remove by id
                    ExerciseManager.shared.removeExercisesById(detail.id)
                    self.collectionView.reloadSections(IndexSet(integer: 3))
                    self.showToast(message: "Exercise removed from plan")
                } else {
                    // Not present -> present AddExerciseViewController prefilled (carry id)
                    let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
                    if let addVC = storyboard.instantiateViewController(withIdentifier: "AddExerciseViewController") as? AddExerciseViewController {
                        addVC.delegate = self // So didAddExercise is called when Save tapped
                        addVC.initialName = detail.title
                        addVC.initialID = detail.id           // <<< important: carry the id
                        addVC.modalPresentationStyle = .pageSheet
                        if let sheet = addVC.sheetPresentationController {
                            sheet.detents = [.large()]
                            sheet.prefersGrabberVisible = true
                        }
                        self.present(addVC, animated: true, completion: nil)
                    }
                }
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
        
        // Note: actual add logic is handled via didAddExercise (delegate) or direct model calls above
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
