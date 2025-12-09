//
//  MindfulnessDetailViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/12/25.
//

import UIKit

class MindfulnessViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case header
        case emotions
        case slideCard
        case explore
    }

    var selectedEmotionIndex: Int? = nil   // nil means emotion picker visible
    
    // Page view controller & slides state
    private var pageVC: UIPageViewController?
    private var slides: [MindfulnessSlide] = []
    private var currentPageIndex = 0

    // Track whether pageVC has been attached to cell host
    private var pageVCAttachedToHost: UIView? = nil

    private var attachedPageControl: UIPageControl?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(UINib(nibName: "HeaderCell", bundle: nil),
                                forCellWithReuseIdentifier: "HeaderCell")

        collectionView.register(UINib(nibName: "EmotionPickerCell", bundle: nil),
                                forCellWithReuseIdentifier: "EmotionPickerCell")

        collectionView.register(UINib(nibName: "SlideCardCell", bundle: nil),
                                forCellWithReuseIdentifier: "SlideCardCell")

        collectionView.register(UINib(nibName: "ExploreCell", bundle: nil),
                                forCellWithReuseIdentifier: "ExploreCell")
        
    }

    private func handleEmotionTap(_ index: Int) {
        selectedEmotionIndex = index
        setupSlides(for: index)     // <-- REQUIRED

        collectionView.performBatchUpdates {
            collectionView.reloadSections(IndexSet(integer: Section.emotions.rawValue))
            collectionView.reloadSections(IndexSet(integer: Section.slideCard.rawValue))
        }
    }


    private func slideVC(at index: Int) -> SlideContentViewController? {
        guard index >= 0, index < slides.count else { return nil }
        let vc = SlideContentViewController(nibName: "SlideContentViewController", bundle: nil)
        vc.slide = slides[index]
        vc.pageIndex = index   // add pageIndex property to SlideContentViewController
        vc.didTapButton = { [weak self] in
            self?.handleSlideButtonTap(index: index)
        }
        return vc
    }
    
    private func attachPageViewController(to hostView: UIView, pageControl: UIPageControl) {
        // if already attached to same host, do nothing
        if pageVCAttachedToHost === hostView { return }

        // remove from old host (if any)
        if let old = pageVCAttachedToHost {
            detachPageViewController(from: old)
        }

        // create pageVC if not exists
        if pageVC == nil {
            pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            pageVC?.dataSource = self
            pageVC?.delegate = self
        }

        guard let pageVC = pageVC else { return }

        // set initial controller
        if let first = slideVC(at: 0) {
            pageVC.setViewControllers([first], direction: .forward, animated: false, completion: nil)
            currentPageIndex = 0
        }

        // add as child to this view controller
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

        // remember host for cleanup
        pageVCAttachedToHost = hostView

        // wire pageControl
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0

        // keep a reference to the cell's pageControl to update in delegate callbacks
        self.attachedPageControl = pageControl
    }

    private func detachPageViewController(from hostView: UIView) {
        guard pageVCAttachedToHost === hostView else { return }
        guard let pageVC = pageVC else { return }

        pageVC.willMove(toParent: nil)
        pageVC.view.removeFromSuperview()
        pageVC.removeFromParent()
        pageVCAttachedToHost = nil

        // if you want to completely destroy pageVC to free memory, set nil:
        // self.pageVC = nil
        // self.attachedPageControl = nil
    }
    
    // Data source
    func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let s = vc as? SlideContentViewController, let idx = s.pageIndex else { return nil }
        return slideVC(at: idx - 1)
    }

    func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let s = vc as? SlideContentViewController, let idx = s.pageIndex else { return nil }
        return slideVC(at: idx + 1)
    }

    // Delegate
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
        // handle Begin/Add Photo...
    }
    
    private func setupSlides(for emotionIndex: Int) {
        switch emotionIndex {
        case 0: // Happy
            slides = [
                /* your happy slides */
            ]

        case 1: // Sad
            slides = [
                MindfulnessSlide(title: "It's okay to have days like this",
                                 description: "Let’s take a small step to feel better.",
                                 buttonText: "Next"),
                MindfulnessSlide(title: "Gentle Breathing",
                                 description: "Try a 3-minute calming session.",
                                 buttonText: "Begin"),
                MindfulnessSlide(title: "Reflect Through Journaling",
                                 description: "Write what's on your mind.",
                                 buttonText: "Begin"),
                MindfulnessSlide(title: "Try Color Your Feelings",
                                 description: "Draw something joyful.",
                                 buttonText: "Add Photo")
            ]

        case 2: // Anxious
            slides = [
                /* your anxious slides */
            ]

        case 3: // Tired
            slides = [
                /* your tired slides */
            ]

        default:
            slides = []
        }
    }
}


extension MindfulnessViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        let sec = Section(rawValue: section)!

        switch sec {
        case .header:
            return 1

        case .emotions:
            return selectedEmotionIndex == nil ? 1 : 0  // hide when emotion selected

        case .slideCard:
            return selectedEmotionIndex == nil ? 0 : 1  // show when emotion selected

        case .explore:
            return 2  // breathing + journaling
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sec = Section(rawValue: indexPath.section)!

        switch sec {

        case .header:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.imageView.image = UIImage(named: "HeaderImage")
            return cell

        case .emotions:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmotionPickerCell", for: indexPath) as! EmotionPickerCell
            
            cell.didSelectEmotion = { [weak self] index in
                self?.handleEmotionTap(index)
            }
            return cell

        case .slideCard:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideCardCell", for: indexPath) as! SlideCardCell
            cell.configure(initialSlidesCount: 4)
            // We'll attach the PageViewController in Step 3
            return cell

        case .explore:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCell", for: indexPath) as! ExploreCell
            // We will configure explore items later (step 4)
            return cell
        }
    }
}


extension MindfulnessViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width

        switch Section(rawValue: indexPath.section)! {

        case .header:
            return CGSize(width: width, height: 200)

        case .emotions:
            return CGSize(width: width, height: 232)

        case .slideCard:
            return CGSize(width: width, height: 232)

        case .explore:
            return CGSize(width: width, height: 130)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard Section(rawValue: indexPath.section) == .slideCard else { return }
        guard let slideCell = cell as? SlideCardCell else { return }

        // Attach PageViewController to the host view in the cell
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

