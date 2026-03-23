import UIKit
import AVKit
import AVFoundation

class ExercisePlayerViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Public Properties (set by the presenting VC before pushing)
    var exerciseModel: NewExerciseModel!
    var exercisePlan: NewExercisePlan!
    var currentIndex: Int = 0
    var onExerciseMarkedDone: ((Int) -> Void)?

    // MARK: - Private Properties
    private var dataSource: ExercisePlayerDataSource!
    weak var activeVideoCell: VideoPlayerCell?
    private var totalDuration: Double = 1.0

    private var currentVideoHeight: CGFloat = 350 {
        didSet {
            VideoPlayerCell.videoHeight = currentVideoHeight
            collectionView?.reloadSections(IndexSet(integer: 0))
        }
    }

    private var popoverBackgroundView: UIView?
    private var popoverCardView: UIView?
    private var popoverArrow: CAShapeLayer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.94, alpha: 1.0)
        VideoPlayerCell.videoHeight = currentVideoHeight
        title = exerciseModel.title
        setupDataSource()
        setupCollectionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activeVideoCell?.pause()
        dismissPopover(animated: false)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        dismissPopover(animated: false)
    }

    // MARK: - Setup
    private func setupDataSource() {
        dataSource = ExercisePlayerDataSource(
            exercise: exerciseModel,
            plan: exercisePlan,
            index: currentIndex
        )
        dataSource.delegate = self
    }

    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.backgroundColor = .clear

        collectionView.register(
            UINib(nibName: "VideoPlayerCell", bundle: nil),
            forCellWithReuseIdentifier: "VideoPlayerCell")
        collectionView.register(
            UINib(nibName: "ExerciseInfoCell", bundle: nil),
            forCellWithReuseIdentifier: "ExerciseInfoCell")
        collectionView.register(
            UINib(nibName: "VideoControlsCell", bundle: nil),
            forCellWithReuseIdentifier: "VideoControlsCell")
        collectionView.register(
            UINib(nibName: "ActionButtonsCell", bundle: nil),
            forCellWithReuseIdentifier: "ActionButtonsCell")
    }

    // MARK: - Compositional Layout
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self else { return nil }
            switch sectionIndex {
            case 0: return self.videoSection()
            case 1: return self.infoSection()
            case 2: return self.controlsSection()
            case 3: return self.buttonsSection()
            default: return nil
            }
        }
    }

    private func videoSection() -> NSCollectionLayoutSection {
        let h = VideoPlayerCell.videoHeight + 40
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(h))
        let section = NSCollectionLayoutSection(group: .vertical(layoutSize: size, subitems: [.init(layoutSize: size)]))
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 45, bottom: 0, trailing: 45)
        return section
    }

    private func infoSection() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180))
        return NSCollectionLayoutSection(group: .vertical(layoutSize: size, subitems: [.init(layoutSize: size)]))
    }

    private func controlsSection() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(140))
        return NSCollectionLayoutSection(group: .vertical(layoutSize: size, subitems: [.init(layoutSize: size)]))
    }

    private func buttonsSection() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(88))
        let section = NSCollectionLayoutSection(group: .vertical(layoutSize: size, subitems: [.init(layoutSize: size)]))
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0)
        return section
    }

    // MARK: - Navigation
    private func pushNextExercise() {
        let nextIndex = currentIndex + 1
        guard nextIndex < exercisePlan.exercises.count else { return }

        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        guard let nextVC = storyboard.instantiateViewController(
            withIdentifier: "ExercisePlayerViewController") as? ExercisePlayerViewController
        else { return }

        nextVC.exercisePlan  = exercisePlan
        nextVC.exerciseModel = exercisePlan.exercises[nextIndex]
        nextVC.currentIndex  = nextIndex
        navigationController?.pushViewController(nextVC, animated: true)
    }

    // MARK: - Toast
    func showToast(message: String, duration: TimeInterval = 1.2) {
        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.12, alpha: 0.88)
        label.textColor = .white
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true

        let padding: CGFloat = 16
        var size = label.sizeThatFits(CGSize(width: view.bounds.width - 60 - padding * 2, height: .greatestFiniteMagnitude))
        size.width += padding * 2
        size.height += 12
        label.frame = CGRect(x: (view.bounds.width - size.width) / 2,
                             y: view.bounds.height - size.height - 140,
                             width: size.width, height: size.height)
        label.alpha = 0
        view.addSubview(label)

        UIView.animate(withDuration: 0.18) { label.alpha = 1 } completion: { _ in
            UIView.animate(withDuration: 0.18, delay: duration) { label.alpha = 0 } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }

    // MARK: - Benefits / Precautions Popover
    func showBenefitsPopover(from anchorButton: UIButton, benefits: [String], precautions: [String]) {
        dismissPopover(animated: false)
        guard let window = view.window else { return }

        let bg = UIView(frame: window.bounds)
        bg.backgroundColor = UIColor(white: 0, alpha: 0.18)
        bg.alpha = 0
        window.addSubview(bg)
        popoverBackgroundView = bg
        bg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))

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
        stack.axis = .vertical; stack.spacing = 12; stack.alignment = .fill
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
            let l = UILabel(); l.text = text
            l.font = .systemFont(ofSize: 18, weight: .semibold); l.textColor = .black
            return l
        }
        func makeRow(systemIcon: String, text: String) -> UIView {
            let h = UIStackView(); h.axis = .horizontal; h.spacing = 10; h.alignment = .center
            let iv = UIImageView(image: UIImage(systemName: systemIcon))
            iv.tintColor = .systemGray; iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 26).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 26).isActive = true
            iv.layer.cornerRadius = 13; iv.clipsToBounds = true
            iv.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.25)
            let l = UILabel(); l.text = text; l.font = .systemFont(ofSize: 15)
            l.textColor = .darkGray; l.numberOfLines = 0
            h.addArrangedSubview(iv); h.addArrangedSubview(l)
            return h
        }

        stack.addArrangedSubview(makeHeader("View Benefits"))
        benefits.forEach { stack.addArrangedSubview(makeRow(systemIcon: "checkmark", text: $0)) }
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 6).isActive = true
        stack.addArrangedSubview(spacer)
        stack.addArrangedSubview(makeHeader("View Precautions"))
        precautions.forEach { stack.addArrangedSubview(makeRow(systemIcon: "exclamationmark", text: $0)) }

        let targetHeight = min(420, CGFloat(benefits.count + precautions.count) * 50 + 120)
        let anchorRect = anchorButton.convert(anchorButton.bounds, to: window)
        let cardWidth: CGFloat = min(290, window.bounds.width - 40)
        let leadingX = max(20, anchorRect.minX - 10 - cardWidth)
        let centerY = max(20 + targetHeight / 2, min(window.bounds.height - 20 - targetHeight / 2, anchorRect.midY))

        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: cardWidth),
            card.heightAnchor.constraint(equalToConstant: targetHeight),
            card.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: leadingX),
            card.centerYAnchor.constraint(equalTo: window.topAnchor, constant: centerY)
        ])

        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.view.window, let card = self.popoverCardView else { return }
            window.layoutIfNeeded(); card.layoutIfNeeded()
            let cf = card.frame
            let tipY = max(cf.minY + 18, min(cf.maxY - 18, anchorRect.midY))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: cf.maxX, y: tipY - 9))
            path.addLine(to: CGPoint(x: cf.maxX + 10, y: tipY))
            path.addLine(to: CGPoint(x: cf.maxX, y: tipY + 9))
            path.close()
            let arrow = CAShapeLayer()
            arrow.path = path.cgPath; arrow.fillColor = UIColor.white.cgColor
            arrow.name = "popoverArrow"
            card.layer.superlayer?.insertSublayer(arrow, below: card.layer)
            self.popoverArrow = arrow
        }

        card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).translatedBy(x: 0, y: -8)
        card.alpha = 0
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
            bg.alpha = 1; card.transform = .identity; card.alpha = 1
        }
    }

    @objc private func backgroundTapped() { dismissPopover() }

    private func dismissPopover(animated: Bool = true) {
        popoverArrow?.removeFromSuperlayer(); popoverArrow = nil
        guard let card = popoverCardView else {
            popoverBackgroundView?.removeFromSuperview(); popoverBackgroundView = nil; return
        }
        let cleanup = { [weak self] in
            card.removeFromSuperview(); self?.popoverCardView = nil
            self?.popoverBackgroundView?.removeFromSuperview(); self?.popoverBackgroundView = nil
        }
        if animated {
            UIView.animate(withDuration: 0.14, animations: {
                card.alpha = 0; self.popoverBackgroundView?.alpha = 0
                card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).translatedBy(x: 0, y: -6)
            }, completion: { _ in cleanup() })
        } else { cleanup() }
    }
}

// MARK: - ExercisePlayerDataSourceDelegate
extension ExercisePlayerViewController: ExercisePlayerDataSourceDelegate {

    func didConfigureVideoCell(_ cell: VideoPlayerCell) {
        activeVideoCell = cell
    }

    func didUpdateTotalDuration(_ seconds: Double) {
        totalDuration = seconds
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(integer: 2))
        }
    }

    func didTapInfo(from button: UIButton) {
        let benefits    = ["Improves shoulder flexibility", "Reduces stiffness",
                           "Enhances range of motion",     "Promotes lymphatic drainage"]
        let precautions = ["Stop if you feel sharp pain",  "Keep breathing steadily",
                           "Move slowly and controlled",   "Stay within your comfort zone"]
        showBenefitsPopover(from: button, benefits: benefits, precautions: precautions)
    }

    func didTogglePlayPause() {
        guard let player = activeVideoCell?.player else { return }
        player.timeControlStatus == .playing ? activeVideoCell?.pause() : activeVideoCell?.play()
    }

    func didRestart() {
        activeVideoCell?.seek(to: 0)
        activeVideoCell?.play()
    }

    func didToggleLoop(enabled: Bool) {
        activeVideoCell?.isLooping = enabled
    }

    func didSeek(toProgress progress: Float) {
        activeVideoCell?.seek(to: Double(progress) * totalDuration)
    }

    func didTapMarkAsDone() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 3)) as? ActionButtonsCell {
            if cell.isDone {
                showToast(message: "Exercise marked as done ✓")
                onExerciseMarkedDone?(currentIndex)
                CoinRewardService.shared.awardExerciseCoinsIfEligible(on: self)
            }
        }
    }


    func didTapNext() {
        pushNextExercise()
    }
}
