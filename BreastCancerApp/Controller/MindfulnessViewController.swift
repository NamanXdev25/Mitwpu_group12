//
//  MindfulnessDetailViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/12/25.
//

import UIKit

class MindfulnessViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    private var gradientImageLayer: CALayer?

    
    private let moodKeys = ["happy", "sad", "anxious", "tired"]
    private var mindfulnessData = MindfulnessDataLoader.shared
    
    // datasource
    private var dataSource: MindfulnessDataSource!
    
    enum Section: Int, CaseIterable {
        case emotions
        case slideCard
        case explore
    }

    var selectedEmotionIndex: Int? = nil
    
    // page VC variables
    private var pageVC: UIPageViewController?
    var slides: [MindfulnessSlide] = []
    private var currentPageIndex = 0
    private var pageVCAttachedToHost: UIView? = nil
    private var attachedPageControl: UIPageControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.setCollectionViewLayout(createCompositionalLayout(), animated: false)
        
        dataSource = MindfulnessDataSource(viewController: self)
        collectionView.dataSource = dataSource
        
        collectionView.delegate = self
        
        collectionView.allowsSelection = true

        // register cell XIBs
        collectionView.register(
            UINib(nibName: "MindfulnessExploreLabelCell", bundle: nil),
            forCellWithReuseIdentifier: "MindfulnessExploreLabelCell"
        )
        collectionView.register(UINib(nibName: "EmotionPickerCell", bundle: nil),
                                forCellWithReuseIdentifier: "EmotionPickerCell")

        collectionView.register(UINib(nibName: "MindfulnessSlideCardCell", bundle: nil),
                                forCellWithReuseIdentifier: "MindfulnessSlideCardCell")

        collectionView.register(UINib(nibName: "MindfulnessExploreCell", bundle: nil),
                                forCellWithReuseIdentifier: "MindfulnessExploreCell")
        
    }
    
    override func viewDidLayoutSubviews() { // runs after Auto Layout, safe area is applied already
        super.viewDidLayoutSubviews()
        applyFadeGradient()
    }
    
    // top image as gradient
    private func applyFadeGradient() {
        if gradientImageLayer == nil {
            let imageLayer = CALayer()
            imageLayer.contents = UIImage(named: "MindfulnessHeaderImage")!.cgImage
            imageLayer.contentsGravity = .resizeAspectFill

            let maskLayer = CAGradientLayer()
            maskLayer.colors = [
                UIColor.black.cgColor,
                UIColor.clear.cgColor
            ]
            maskLayer.locations = [0.68, 1.0]

            imageLayer.mask = maskLayer
            gradientView.layer.addSublayer(imageLayer)
            gradientImageLayer = imageLayer
        }

        gradientImageLayer?.frame = gradientView.bounds
        gradientImageLayer?.mask?.frame = gradientView.bounds
    }

    func handleEmotionTap(_ index: Int) {
        selectedEmotionIndex = index
        setupSlides(for: index)
        collectionView.performBatchUpdates {
            collectionView.reloadSections(IndexSet(integer: Section.emotions.rawValue))
            collectionView.reloadSections(IndexSet(integer: Section.slideCard.rawValue))
        }
    }

// Slides (for mood recomendation) / Page View Controller setup
    
    private func slideVC(at index: Int) -> SlideContentViewController? {
        guard index >= 0, index < slides.count else { return nil }
        let vc = SlideContentViewController(nibName: "SlideContentViewController", bundle: nil)
        vc.slide = slides[index]
        vc.pageIndex = index
        vc.didTapButton = { [weak self] in
            self?.handleSlideButtonTap(index: index)
        }
        return vc
    }
    
    private func attachPageViewController(to hostView: UIView, pageControl: UIPageControl) {
        
        if pageVCAttachedToHost === hostView { return }

        if let old = pageVCAttachedToHost {
            detachPageViewController(from: old)
        }

        if pageVC == nil {
            pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            pageVC?.dataSource = self
            pageVC?.delegate = self
        }

        guard let pageVC = pageVC else { return }
        if let first = slideVC(at: 0) {
            pageVC.setViewControllers([first], direction: .forward, animated: false, completion: nil)
            currentPageIndex = 0
        }

        addChild(pageVC)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(pageVC.view)

        NSLayoutConstraint.activate([
            pageVC.view.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            pageVC.view.topAnchor.constraint(equalTo: hostView.topAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: hostView.bottomAnchor)
        ])

        pageVC.didMove(toParent: self)
        pageVCAttachedToHost = hostView

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0

        self.attachedPageControl = pageControl
    }

    private func detachPageViewController(from hostView: UIView) {
        guard pageVCAttachedToHost === hostView else { return }
        guard let pageVC = pageVC else { return }

        pageVC.willMove(toParent: nil)
        pageVC.view.removeFromSuperview()
        pageVC.removeFromParent()
        pageVCAttachedToHost = nil

    }
    
    func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let s = vc as? SlideContentViewController, let idx = s.pageIndex else { return nil }
        return slideVC(at: idx - 1)
    }

    func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let s = vc as? SlideContentViewController, let idx = s.pageIndex else { return nil }
        return slideVC(at: idx + 1)
    }

    func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let current = pvc.viewControllers?.first as? SlideContentViewController,
              let idx = current.pageIndex else { return }
        currentPageIndex = idx
        attachedPageControl?.currentPage = idx
    }

    private func handleSlideButtonTap(index: Int) {
        let slide = slides[index]
        
        switch slide.action {
        case .next:
            let next = index + 1
            if let nextVC = slideVC(at: next) {
                pageVC?.setViewControllers(
                    [nextVC],
                    direction: .forward,
                    animated: true
                ) { [weak self] _ in
                    self?.currentPageIndex = next
                    self?.attachedPageControl?.currentPage = next
                }
            }

        case .begin:
            guard let destination = slide.destination else { return }

            switch destination {
            case .breathing(let sessionID):
                openBreathingSession(id: sessionID)

            case .journalBlank:
                openBlankJournal()
            }

        case .addPhoto:
            print("Add photo tapped")
        }
    }
    
    private func openBreathingSession(id: String) {
        let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)

        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "BreathingPlayerVC"
        ) as? BreathingPlayerViewController else {
            assertionFailure("BreathingPlayerViewController not found")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openBlankJournal() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)

        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "BlankJournalViewController"
        ) as? BlankJournalViewController else {
            assertionFailure("BlankJournalViewController not found")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupSlides(for emotionIndex: Int) {
        slides.removeAll()

        let moodKey = (0 ..< moodKeys.count).contains(emotionIndex) ? moodKeys[emotionIndex] : moodKeys[0]
        guard let moodContent = mindfulnessData.moodContent(for: moodKey) else {
            assertionFailure("Missing mood content for key: \(moodKey)")
            slides = []
            return
        }

        let intro = moodContent.intro
        guard
            let breathe = moodContent.breathing.randomElement(),
            let journal = moodContent.journaling.randomElement(),
            let hobby = moodContent.hobby.randomElement()
        else {
            assertionFailure("Empty content arrays for mood: \(moodKey)")
            slides = []
            return
        }

        slides = [
            MindfulnessSlide(
                title: intro.title,
                description: intro.description,
                buttonText: intro.buttonText ?? "Next",
                action: .next,
                destination: nil
            ),
            MindfulnessSlide(
                title: breathe.title,
                description: breathe.description,
                buttonText: breathe.buttonText ?? "Begin",
                action: .begin,
                destination: .breathing(sessionID: "gentle_focus")
            ),
            MindfulnessSlide(
                title: journal.title,
                description: journal.description,
                buttonText: journal.buttonText ?? "Begin",
                action: .begin,
                destination: .journalBlank
            ),
            MindfulnessSlide(
                title: hobby.title,
                description: hobby.description,
                buttonText: hobby.buttonText ?? "Add Photo",
                action: .addPhoto,
                destination: nil
            )
        ]
    }
    
// Compositional Layout (collectionv view)
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            switch section {

            case .explore:
                let labelItem = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1),
                                      heightDimension: .absolute(40))
                )

                let cardItem = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1),
                                      heightDimension: .absolute(116))
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(widthDimension: .fractionalWidth(1),
                                      heightDimension: .estimated(300)),
                    subitems: [labelItem, cardItem, cardItem]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 12, leading: 0, bottom: 12, trailing: 0)
                return section

            case .emotions:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    )
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    ),
                    subitems: [item]
                )
                return NSCollectionLayoutSection(group: group)

            case .slideCard:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    )
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    ),
                    subitems: [item]
                )
                return NSCollectionLayoutSection(group: group)
            }
        }
    }
    
    private func handleExploreTap(at index: Int) {
        guard index != 0 else { return }

        switch index {
        case 1:
            openBreathingSessions()
        case 2:
            openJournal()
            
        default:
            break
        }
    }
    
    private func openJournal() {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        

        guard let journalVC = storyboard.instantiateViewController(
            withIdentifier: "JournalViewController"
        ) as? JournalViewController else {
            fatalError("JournalViewController not found in Journal.storyboard")
        }

        navigationController?.pushViewController(journalVC, animated: true)
    }
    
    private func openBreathingSessions() {
        let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)

        guard let breathingVC = storyboard.instantiateViewController(
            withIdentifier: "BreathingSessionsViewController"
        ) as? BreathingViewController else {
            fatalError("BreathingSessionsViewController not found in BretahingSessions.storyboard")
        }
        navigationController?.pushViewController(breathingVC, animated: true)
    }

}

extension MindfulnessViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard Section(rawValue: indexPath.section) == .slideCard else { return }
        guard let slideCell = cell as? MindfulnessSlideCardCell else { return }

        attachPageViewController(to: slideCell.pageHostView,
                                 pageControl: slideCell.pageControl)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if Section(rawValue: indexPath.section) == .slideCard,
           let slideCell = cell as? MindfulnessSlideCardCell {
            if pageVCAttachedToHost === slideCell.pageHostView {
                detachPageViewController(from: slideCell.pageHostView)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        print("DID SELECT:", indexPath)

        guard let section = Section(rawValue: indexPath.section) else { return }

        if section == .explore {
            handleExploreTap(at: indexPath.item)
        }
    }

}

extension MindfulnessViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {}
