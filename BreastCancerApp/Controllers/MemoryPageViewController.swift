import UIKit

final class MemoryPageViewController: UIPageViewController {

    // MARK: - Data
    var memories: [Memory] = []
    var startIndex: Int = 0

    weak var deleteDelegate: MemoryDeleteDelegate?

    private var currentIndex = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageController()
        configureInitialViewController()
        addGlassBackButton()
        addGlassDeleteButton()
    }
}

// MARK: - Configuration
private extension MemoryPageViewController {

    func configurePageController() {
        dataSource = self
        delegate = self
        view.backgroundColor = .white
        currentIndex = startIndex
    }

    func configureInitialViewController() {
        let startVC = viewerController(at: startIndex)
        setViewControllers([startVC], direction: .forward, animated: false)
    }
}

// MARK: - Child Viewer VC
private extension MemoryPageViewController {

    func viewerController(at index: Int) -> MemoryViewerViewController {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "MemoryViewerViewController"
        ) as! MemoryViewerViewController

        let memory = memories[index]
        vc.image = memory.image
        vc.note = memory.note
        vc.view.tag = index
        vc.view.backgroundColor = .white

        return vc
    }
}

// MARK: - Glass Buttons
private extension MemoryPageViewController {

    func addGlassBackButton() {
        let blur = glassButton(
            systemImage: "chevron.left",
            action: #selector(backTapped)
        )

        view.addSubview(blur)

        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            blur.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 12
            )
        ])
    }

    func addGlassDeleteButton() {
        let blur = glassButton(
            systemImage: "trash",
            action: #selector(deleteTapped)
        )

        view.addSubview(blur)

        NSLayoutConstraint.activate([
            blur.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            blur.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            )
        ])
    }

    func glassButton(systemImage: String, action: Selector) -> UIVisualEffectView {
        let blurView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemUltraThinMaterial)
        )
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 22
        blurView.clipsToBounds = true

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: systemImage), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: action, for: .touchUpInside)

        blurView.contentView.addSubview(button)

        NSLayoutConstraint.activate([
            blurView.widthAnchor.constraint(equalToConstant: 44),
            blurView.heightAnchor.constraint(equalToConstant: 44),
            button.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])

        return blurView
    }
}

// MARK: - Actions
private extension MemoryPageViewController {

    @objc func backTapped() {
        dismiss(animated: true)
    }

    @objc func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Photo",
            message: "This photo will be permanently deleted.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.performDelete()
            }
        )

        present(alert, animated: true)
    }

    func performDelete() {
        deleteDelegate?.didDeleteMemory(at: currentIndex)
        memories.remove(at: currentIndex)

        guard !memories.isEmpty else {
            dismiss(animated: true)
            return
        }

        let nextIndex = min(currentIndex, memories.count - 1)
        currentIndex = nextIndex

        let nextVC = viewerController(at: nextIndex)
        setViewControllers([nextVC], direction: .forward, animated: true)
    }
}

// MARK: - Paging
extension MemoryPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        let index = viewController.view.tag
        guard index > 0 else { return nil }
        return viewerController(at: index - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let index = viewController.view.tag
        guard index < memories.count - 1 else { return nil }
        return viewerController(at: index + 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentVC = viewControllers?.first else { return }
        currentIndex = currentVC.view.tag
    }
}
