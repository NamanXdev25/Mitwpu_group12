import UIKit

final class BreathingPlayerRootView: UIView {
    @IBOutlet var backgroundImageView: UIImageView!

    func showBackground(animated: Bool = true) {
        let animations = {
            self.backgroundImageView.alpha = 1
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: animations)
        } else {
            animations()
        }
    }

    func hideBackground(animated: Bool = true) {
        let animations = {
            self.backgroundImageView.alpha = 0
        }

        if animated {
            UIView.animate(withDuration: 0.5, animations: animations)
        } else {
            animations()
        }
    }
}
