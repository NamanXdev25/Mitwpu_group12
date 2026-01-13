import UIKit

final class MemoryPageViewController: UIPageViewController {

    var images: [UIImage] = []
    var startIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        view.backgroundColor = .black

        let startVC = imageViewController(at: startIndex)
        setViewControllers([startVC], direction: .forward, animated: false)
    }

    fileprivate func imageViewController(at index: Int) -> MemoryViewerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "MemoryViewerViewController"
        ) as! MemoryViewerViewController

        vc.image = images[index]
        vc.view.tag = index   // used to track page index
        return vc
    }
}

// ✅ EXTENSION MUST BE OUTSIDE THE CLASS
extension MemoryPageViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {

        let index = viewController.view.tag
        guard index > 0 else { return nil }
        return imageViewController(at: index - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {

        let index = viewController.view.tag
        guard index < images.count - 1 else { return nil }
        return imageViewController(at: index + 1)
    }
}
