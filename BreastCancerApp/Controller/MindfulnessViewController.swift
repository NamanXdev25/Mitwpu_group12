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
    
    private let moodKeys = ["happy", "sad", "anxious", "tired"]
    private var mindfulnessData = MindfulnessDataLoader.shared

    private var dataSource: MindfulnessDataSource!
    
    enum Section: Int, CaseIterable {
        case emotions
        case slideCard
        case explore
    }

    var selectedEmotionIndex: Int? = nil
    
    private var pageVC: UIPageViewController?
    var slides: [MindfulnessSlide] = []
    private var currentPageIndex = 0
    private var pageVCAttachedToHost: UIView? = nil
    private var attachedPageControl: UIPageControl?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        title = "Mindfulness"
        
        collectionView.setCollectionViewLayout(createCompositionalLayout(), animated: false)
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 132, left: 0, bottom: 0, right: 0)

        
        
        dataSource = MindfulnessDataSource(viewController: self)
        collectionView.dataSource = dataSource

        collectionView.delegate = self


        collectionView.register(
            UINib(nibName: "ExploreLabelCell", bundle: nil),
            forCellWithReuseIdentifier: "ExploreLabelCell"
        )
        collectionView.register(UINib(nibName: "EmotionPickerCell", bundle: nil),
                                forCellWithReuseIdentifier: "EmotionPickerCell")

        collectionView.register(UINib(nibName: "SlideCardCell", bundle: nil),
                                forCellWithReuseIdentifier: "SlideCardCell")

        collectionView.register(UINib(nibName: "ExploreCell", bundle: nil),
                                forCellWithReuseIdentifier: "ExploreCell")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyFadeGradient()
        
    }
    
    private func applyFadeGradient() {

        let image = UIImage(named: "HeaderImage")!.cgImage!

        let imageLayer = CALayer()
        imageLayer.frame = gradientView.bounds
        imageLayer.contents = image
        imageLayer.contentsGravity = .resizeAspectFill

        let maskLayer = CAGradientLayer()
        maskLayer.frame = gradientView.bounds
        maskLayer.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor 
        ]
        maskLayer.locations = [0.68, 1.0]

        imageLayer.mask = maskLayer

        gradientView.layer.sublayers?.removeAll()
        gradientView.layer.addSublayer(imageLayer)
    }



    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Mindfulness"
    }




    func handleEmotionTap(_ index: Int) {
        selectedEmotionIndex = index
        setupSlides(for: index)

        collectionView.performBatchUpdates {
            collectionView.reloadSections(IndexSet(integer: Section.emotions.rawValue))
            collectionView.reloadSections(IndexSet(integer: Section.slideCard.rawValue))
        }
    }


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
        let text = slides[index].buttonText.lowercased()
        if text == "next" {
            let next = index + 1
            if let nextVC = slideVC(at: next) {
                pageVC?.setViewControllers([nextVC], direction: .forward, animated: true, completion: { [weak self] _ in
                    self?.currentPageIndex = next
                    self?.attachedPageControl?.currentPage = next
                })
            }
            return
        }
    }
    
    private func setupSlides(for emotionIndex: Int) {
        slides.removeAll()

        let moodKey = (0 ..< moodKeys.count).contains(emotionIndex) ? moodKeys[emotionIndex] : moodKeys[0]
        guard let moodContent = mindfulnessData.moodContent(for: moodKey) else {
            // fallback: default
            slides = [
                MindfulnessSlide(title: "It's okay to have days like this",
                                 description: "Let’s take a small step to feel better.",
                                 buttonText: "Next"),
                MindfulnessSlide(title: "Gentle Breathing",
                                 description: "Try a 3-minute calming session to reset your breathing and relax your body.",
                                 buttonText: "Begin"),
                MindfulnessSlide(title: "Reflect Through Journaling",
                                 description: "Write down what’s been weighing on your mind today it can help clear your head.",
                                 buttonText: "Begin"),
                MindfulnessSlide(title: "Try Color Your Feelings",
                                 description: "Draw something joyful like the sun, flowers Let the colors brighten your mood.",
                                 buttonText: "Add Photo")
            ]
            return
        }

        let intro = moodContent.intro
        let breathe = moodContent.breathing.randomElement() ?? moodContent.breathing.first!
        let journal = moodContent.journaling.randomElement() ?? moodContent.journaling.first!
        let hobby = moodContent.hobby.randomElement() ?? moodContent.hobby.first!

        slides = [
            MindfulnessSlide(title: intro.title, description: intro.description, buttonText: intro.buttonText ?? "Next"),
            MindfulnessSlide(title: breathe.title, description: breathe.description, buttonText: breathe.buttonText ?? "Begin"),
            MindfulnessSlide(title: journal.title, description: journal.description, buttonText: journal.buttonText ?? "Begin"),
            MindfulnessSlide(title: hobby.title, description: hobby.description, buttonText: hobby.buttonText ?? "Try")
        ]
    }
    
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

}


extension MindfulnessViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard Section(rawValue: indexPath.section) == .slideCard else { return }
        guard let slideCell = cell as? SlideCardCell else { return }

        attachPageViewController(to: slideCell.pageHostView,
                                 pageControl: slideCell.pageControl)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        if Section(rawValue: indexPath.section) == .slideCard,
           let slideCell = cell as? SlideCardCell {

            if pageVCAttachedToHost === slideCell.pageHostView {
                detachPageViewController(from: slideCell.pageHostView)
            }
        }
    }

    
}

extension MindfulnessViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {}

class MindfulnessDataLoader {
    static let shared = MindfulnessDataLoader()

    private(set) var root: MindfulnessJSONRoot?

    private init() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "moodSuggestion", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Mindfulness JSON not found")
            return
        }

        do {
            let dec = JSONDecoder()
            root = try dec.decode(MindfulnessJSONRoot.self, from: data)
        } catch {
            print("JSON decode error:", error)
        }
    }

    func moodContent(for moodKey: String) -> MoodContent? {
        return root?.moods[moodKey]
    }
}
