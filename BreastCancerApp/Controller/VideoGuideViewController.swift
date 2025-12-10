import UIKit

class VideoGuideViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Background color
        view.backgroundColor = UIColor(named: "BGPink") ??
                               UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1)

        // Title centered in navigation bar
        let titleLabel = UILabel()
        titleLabel.text = "Video Guide"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // Navigation bar color match Background
        let nav = navigationController?.navigationBar
        let bg = UIColor(named: "BGPink") ??
                 UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bg

        nav?.standardAppearance = appearance
        nav?.scrollEdgeAppearance = appearance
        nav?.compactAppearance = appearance
    }
}
