//
//  MindfulnessDetailViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 08/12/25.
//

import UIKit

class MindfulnessViewController: UIViewController {

    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var selectedEmotion: String!
    
    private var slides: [MindfulnessSlide] = []
    private var currentIndex = 0

    private var pageVC: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Mindfulness"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSlides()
        guard !slides.isEmpty else {
            // optional: show placeholder or hide cardContainerView
            pageControl.numberOfPages = 0
            return
        }
        setupPageViewController()
        setupPageControl()
    }
    
    private func setupSlides() {

        switch selectedEmotion {
        case "Sad":
            slides = [
                MindfulnessSlide(
                    title: "It’s okay to have days like this",
                    description: "Let’s take a small step to feel better.",
                    buttonText: "Next"
                ),
                MindfulnessSlide(
                    title: "Gentle Breathing",
                    description: "Try a 3-minute calming session to reset your body.",
                    buttonText: "Begin"
                ),
                MindfulnessSlide(
                    title: "Reflect Through Journaling",
                    description: "Write what’s weighing on your mind.",
                    buttonText: "Begin"
                ),
                MindfulnessSlide(
                    title: "Try Color Your Feelings",
                    description: "Draw something joyful. Let colors brighten your mood.",
                    buttonText: "Add Photo"
                )
            ]

        default:
            slides = []
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

    private func setupPageViewController() {
        guard !slides.isEmpty else { return }                       // avoid empty
        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.dataSource = self
        pageVC.delegate = self

        if let initial = slideVC(at: 0) {
            pageVC.setViewControllers([initial], direction: .forward, animated: false, completion: nil)
        }

        addChild(pageVC)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.backgroundColor = .clear
        cardContainerView.addSubview(pageVC.view)

        NSLayoutConstraint.activate([
            pageVC.view.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            pageVC.view.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
        ])

        pageVC.didMove(toParent: self)
    }

    
    private func setupPageControl() {
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
    }
    
    private func handleSlideButtonTap(index: Int) {

        // Example behaviors
        if slides[index].buttonText == "Next" {
            let nextIndex = index + 1
            if nextIndex < slides.count {
                if let nextVC = slideVC(at: nextIndex) {
                    pageVC.setViewControllers([nextVC], direction: .forward, animated: true)
                }
                pageControl.currentPage = nextIndex
                currentIndex = nextIndex
            }
            return
        }

        if slides[index].buttonText == "Begin" {
            print("Start breathing session / journaling")
            return
        }

        if slides[index].buttonText == "Add Photo" {
            print("Launch photo picker")
            return
        }
    }

}

extension MindfulnessViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? SlideContentViewController,
              let index = vc.pageIndex else { return nil }
        
        return slideVC(at: index - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? SlideContentViewController,
              let index = vc.pageIndex else { return nil }
        
        return slideVC(at: index + 1)
    }


    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        guard completed,
              let vc = pageViewController.viewControllers?.first as? SlideContentViewController,
              let index = vc.pageIndex else { return }

        currentIndex = index
        pageControl.currentPage = index
    }

}
