import UIKit

enum NotificationPermissionAlertPresenter {
    private static var isPresenting = false

    static func show(title: String, message: String) {
        DispatchQueue.main.async {
            guard !isPresenting else { return }
            guard let topViewController = topViewController() else { return }

            if topViewController.presentedViewController is UIAlertController { return }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            isPresenting = true
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                isPresenting = false
            })
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                isPresenting = false
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingsURL) else { return }
                UIApplication.shared.open(settingsURL)
            })

            topViewController.present(alert, animated: true)
        }
    }

    private static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    ) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }

        if let tabBarController = base as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(base: selectedViewController)
        }

        if let presentedViewController = base?.presentedViewController {
            return topViewController(base: presentedViewController)
        }

        return base
    }
}
