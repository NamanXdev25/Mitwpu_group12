import UIKit
import AVKit
import AVFoundation

class ExercisePlayerViewController: UIViewController, AddExerciseDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var CalendarButton: UIBarButtonItem!
    
    var exerciseData: DetailExerciseItem?
    var videoPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var isPlaying = false
    var currentTime: Double = 0
    var totalDuration: Double = 240
    
    var currentVideoHeight: CGFloat = 350 {
        didSet {
            VideoPlayerCell.videoHeight = currentVideoHeight
            collectionView?.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private var popoverBackgroundView: UIView?
    private var popoverCardView: UIView?
    private var popoverArrow: CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VideoPlayerCell.videoHeight = currentVideoHeight
        setupCollectionView()
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.94, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadSections(IndexSet(integer: 3))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer?.pause()
        dismissPopover(animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        dismissPopover(animated: false)
    }
    
    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
        
        if let calendarNavController = storyboard.instantiateViewController(withIdentifier: "ExerciseCalendarnav") as? UINavigationController {
            
            calendarNavController.modalPresentationStyle = .pageSheet
            if let sheet = calendarNavController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(calendarNavController, animated: true, completion: nil)
        }
    }
    
    func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
        let totalHeight = VideoPlayerCell.videoHeight + 40
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(totalHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 45, bottom: 0, trailing: 45)
        
        return section
    }
    
    func createInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(180))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    func createControlsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(140))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    func createButtonsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(88))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0)
        
        return section
    }
    
    func didAddExercise(_ exercise: PlanItem) {
        ExerciseManager.shared.addPlanItem(exercise)
        collectionView.reloadSections(IndexSet(integer: 3))
        showToast(message: "Exercise added to plan")
    }
    
    func showToast(message: String, duration: TimeInterval = 1.2) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textAlignment = .center
        toastLabel.alpha = 0
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = UIColor(white: 0.12, alpha: 0.88)
        toastLabel.textColor = .white
        toastLabel.layer.cornerRadius = 14
        toastLabel.layer.masksToBounds = true

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
    
    func showBenefitsPopover(from anchorButton: UIButton, benefits: [String], precautions: [String]) {
        dismissPopover(animated: false)

        guard let window = view.window ?? UIApplication.shared.windows.first else { return }

        let bg = UIView(frame: window.bounds)
        bg.backgroundColor = UIColor(white: 0.0, alpha: 0.18)
        bg.alpha = 0.0
        window.addSubview(bg)
        popoverBackgroundView = bg

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        bg.addGestureRecognizer(tap)

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.masksToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(card)
        popoverCardView = card

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            scroll.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            scroll.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            scroll.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        func makeHeader(_ text: String) -> UILabel {
            let lbl = UILabel()
            lbl.text = text
            lbl.font = .systemFont(ofSize: 18, weight: .semibold)
            lbl.textColor = .black
            return lbl
        }
        func makeBulletRow(icon: UIImage?, text: String) -> UIView {
            let h = UIStackView()
            h.axis = .horizontal
            h.spacing = 10
            h.alignment = .center

            let iv = UIImageView(image: icon)
            iv.tintColor = .systemGray
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 26).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 26).isActive = true
            iv.layer.cornerRadius = 13
            iv.clipsToBounds = true
            iv.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.25)

            let lbl = UILabel()
            lbl.text = text
            lbl.font = .systemFont(ofSize: 15)
            lbl.textColor = .darkGray
            lbl.numberOfLines = 0

            h.addArrangedSubview(iv)
            h.addArrangedSubview(lbl)
            return h
        }

        stack.addArrangedSubview(makeHeader("View Benefits"))
        for b in benefits {
            stack.addArrangedSubview(makeBulletRow(icon: UIImage(systemName: "checkmark"), text: b))
        }

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 6).isActive = true
        stack.addArrangedSubview(spacer)

        stack.addArrangedSubview(makeHeader("View Precautions"))
        for p in precautions {
            stack.addArrangedSubview(makeBulletRow(icon: UIImage(systemName: "exclamationmark"), text: p))
        }

        card.layoutIfNeeded()
        let estimatedRowHeight: CGFloat = 50
        let targetHeight = min(420, CGFloat((benefits.count + precautions.count)) * estimatedRowHeight + 120)

        let anchorRectInWindow = anchorButton.convert(anchorButton.bounds, to: window)
        let cardWidth: CGFloat = min(290, window.bounds.width - 40)

        card.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
        card.heightAnchor.constraint(equalToConstant: targetHeight).isActive = true

        let desiredLeading = anchorRectInWindow.minX - 10 - cardWidth
        let minLeading: CGFloat = 20
        let leadingX = max(minLeading, desiredLeading)
        card.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: leadingX).isActive = true

        let desiredCenterY = anchorRectInWindow.midY
        let halfHeight = targetHeight / 2
        let minCenterY = 20 + halfHeight
        let maxCenterY = window.bounds.height - 20 - halfHeight
        let centerY = max(minCenterY, min(maxCenterY, desiredCenterY))
        card.centerYAnchor.constraint(equalTo: window.topAnchor, constant: centerY).isActive = true

        popoverArrow?.removeFromSuperlayer()
        popoverArrow = nil

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let window = self.view.window else { return }
            guard let card = self.popoverCardView else { return }

            let anchorRect = anchorButton.convert(anchorButton.bounds, to: window)
            window.layoutIfNeeded()
            card.layoutIfNeeded()
            let cardFrame = card.frame

            let arrowWidth: CGFloat = 10
            let arrowHeight: CGFloat = 18
            let verticalInset: CGFloat = 12

            let unclampedTipY = anchorRect.midY
            let minTipY = cardFrame.minY + verticalInset + arrowHeight/2
            let maxTipY = cardFrame.maxY - verticalInset - arrowHeight/2
            let tipY = max(minTipY, min(maxTipY, unclampedTipY))

            let baseX = cardFrame.maxX
            let tipX = baseX + arrowWidth

            let p = UIBezierPath()
            p.move(to: CGPoint(x: baseX, y: tipY - arrowHeight/2))
            p.addLine(to: CGPoint(x: tipX, y: tipY))
            p.addLine(to: CGPoint(x: baseX, y: tipY + arrowHeight/2))
            p.close()

            let arrowLayer = CAShapeLayer()
            arrowLayer.path = p.cgPath
            arrowLayer.fillColor = UIColor.white.cgColor
            arrowLayer.shadowColor = UIColor.black.cgColor
            arrowLayer.shadowOpacity = 0.08
            arrowLayer.shadowOffset = CGSize(width: 0, height: 2)
            arrowLayer.shadowRadius = 6
            arrowLayer.name = "popoverArrow"

            if let superlayer = card.layer.superlayer {
                superlayer.insertSublayer(arrowLayer, below: card.layer)
            } else {
                window.layer.addSublayer(arrowLayer)
            }

            self.popoverArrow = arrowLayer
        }

        card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).translatedBy(x: 0, y: -8)
        card.alpha = 0.0
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut], animations: {
            bg.alpha = 1.0
            card.transform = .identity
            card.alpha = 1.0
        }, completion: nil)
    }
    
    @objc private func backgroundTapped(_ g: UITapGestureRecognizer) {
        dismissPopover(animated: true)
    }

    private func dismissPopover(animated: Bool = true) {
        if let arrow = popoverArrow {
            arrow.removeFromSuperlayer()
            popoverArrow = nil
        }
        if let card = popoverCardView {
            let cleanup = {
                card.removeFromSuperview()
                self.popoverCardView = nil
            }
            if animated {
                UIView.animate(withDuration: 0.14, animations: {
                    card.alpha = 0.0
                    self.popoverBackgroundView?.alpha = 0.0
                    card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).translatedBy(x: 0, y: -6)
                }) { _ in
                    cleanup()
                    self.popoverBackgroundView?.removeFromSuperview()
                    self.popoverBackgroundView = nil
                }
            } else {
                cleanup()
                popoverBackgroundView?.removeFromSuperview()
                popoverBackgroundView = nil
            }
        } else {
            popoverBackgroundView?.removeFromSuperview()
            popoverBackgroundView = nil
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerCell
            cell.configure(imageName: exerciseData?.imageName ?? "girl_stretch")
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseInfoCell", for: indexPath) as! ExerciseInfoCell
            cell.configure(
                title: exerciseData?.title ?? "Wall Climb Stretch",
                description: "A gentle exercise to improve shoulder mobility and range of motion after surgery.",
                level: "Beginner"
            )
            
            cell.onInfoTap = { [weak self] infoButton in
                guard let self = self else { return }
                let benefits = [
                    "Improves shoulder flexibility",
                    "Reduces stiffness",
                    "Enhances range of motion",
                    "Promotes lymphatic drainage"
                ]
                let precautions = [
                    "Stop if you feel sharp pain",
                    "Keep breathing steadily",
                    "Move slowly and controlled",
                    "Stay within your comfort zone"
                ]
                self.showBenefitsPopover(from: infoButton, benefits: benefits, precautions: precautions)
            }
            
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoControlsCell", for: indexPath) as! VideoControlsCell
            cell.configure(currentTime: 0, totalTime: 240)
            
            cell.onPlayPause = { [weak self] in self?.togglePlayPause() }
            cell.onRestart = { [weak self] in self?.restartVideo() }
            cell.onLoop = { [weak self] isLooping in self?.toggleLoop(enabled: isLooping) }
            cell.onSeek = { [weak self] progress in self?.seekToProgress(progress) }
            
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionButtonsCell", for: indexPath) as! ActionButtonsCell
            
            let alreadyAdded = (exerciseData != nil) ? ExerciseManager.shared.containsExercise(id: exerciseData!.id) : false
            cell.setAdded(alreadyAdded)
            
            cell.onAddToPlan = { [weak self] in
                guard let self = self, let detail = self.exerciseData else { return }
                
                if ExerciseManager.shared.containsExercise(id: detail.id) {
                    ExerciseManager.shared.removeExercisesById(detail.id)
                    self.collectionView.reloadSections(IndexSet(integer: 3))
                    self.showToast(message: "Exercise removed from plan")
                } else {
                    let storyboard = UIStoryboard(name: "Exercise", bundle: nil)
                    
                    if let addNavController = storyboard.instantiateViewController(withIdentifier: "AddExercisenav") as? UINavigationController {
                        
                        if let addVC = addNavController.viewControllers.first as? AddExerciseViewController {
                            addVC.delegate = self
                            addVC.initialName = detail.title
                            addVC.initialID = detail.id
                            addVC.isNameEditable = false
                        }
                        
                        addNavController.modalPresentationStyle = .pageSheet
                        if let sheet = addNavController.sheetPresentationController {
                            sheet.detents = [.large()]
                            sheet.prefersGrabberVisible = true
                        }
                        
                        self.present(addNavController, animated: true, completion: nil)
                    }
                }
            }
            
            cell.onSetReminder = { [weak self] in self?.setReminder() }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func togglePlayPause() { print("▶️/⏸️ Play/Pause tapped") }
    func restartVideo() { print("⏮️ Restart tapped") }
    func toggleLoop(enabled: Bool) { print("🔁 Loop \(enabled)") }
    func seekToProgress(_ progress: Float) { print("⏩ Seeked") }
    func addToPlan() {}
    
    func setReminder() {
        print("⏰ Set Reminder tapped")
        let alert = UIAlertController(title: "Set Reminder", message: "Reminder feature coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
