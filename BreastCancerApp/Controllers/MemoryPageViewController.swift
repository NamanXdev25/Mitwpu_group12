import UIKit

final class MemoryPageViewController: UIPageViewController {

    var images: [UIImage] = []
    var startIndex: Int = 0

    weak var deleteDelegate: MemoryDeleteDelegate?

    private var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        view.backgroundColor = .white
        currentIndex = startIndex

        let startVC = imageViewController(at: startIndex)
        setViewControllers([startVC], direction: .forward, animated: false)

        addGlassBackButton()
        addGlassDeleteButton()
    }

    private func imageViewController(at index: Int) -> MemoryViewerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "MemoryViewerViewController"
        ) as! MemoryViewerViewController

        vc.image = images[index]
        vc.view.tag = index
        vc.view.backgroundColor = .white
        return vc
    }

    // MARK: - Glass Back Button
    private func addGlassBackButton() {
        let blur = glassButton(
            systemImage: "chevron.left",
            action: #selector(backTapped)
        )

        view.addSubview(blur)

        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            blur.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }

    // MARK: - Glass Delete Button
    private func addGlassDeleteButton() {
        let blur = glassButton(
            systemImage: "trash",
            action: #selector(deleteTapped)
        )

        view.addSubview(blur)

        NSLayoutConstraint.activate([
            blur.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            blur.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Glass Button Factory
    private func glassButton(systemImage: String, action: Selector) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 22
        blurView.clipsToBounds = true

        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemImage), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Photo",
            message: "This photo will be permanently deleted.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteDelegate?.didDeleteMemory(at: self.currentIndex)
            self.dismiss(animated: true)
        })

        present(alert, animated: true)
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

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed,
           let currentVC = viewControllers?.first {
            currentIndex = currentVC.view.tag
        }
    }
}
