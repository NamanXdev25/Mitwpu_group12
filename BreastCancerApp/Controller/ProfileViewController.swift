import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Constants
    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 16
        static let lineSpacing: CGFloat = 8

        static let profileHeaderHeight: CGFloat = 160
        static let healthStatusHeight: CGFloat = 72
        static let notificationsHeaderHeight: CGFloat = 20
        static let notificationTogglesHeight: CGFloat = 208
    }

    private enum Strings {
        static let profileName = "Sophie Chen"
        static let healthStatusTitle = "Health Status"
        static let notificationsTitle = "Notifications"
        static let storyboardName = "Main"
        static let healthStatusVCIdentifier = "HealthStatusViewController"
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        registerCells()
    }

    // MARK: - Setup
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: ProfileHeaderCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: ProfileHeaderCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: HealthStatusCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: HealthStatusCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: NotificationsHeaderCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: NotificationsHeaderCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: NotificationTogglesCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: NotificationTogglesCell.reuseIdentifier
        )
    }

    // MARK: - Navigation
    private func presentHealthStatus() {
        let storyboard = UIStoryboard(name: Strings.storyboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: Strings.healthStatusVCIdentifier
        ) as! HealthStatusViewController

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        4
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        switch indexPath.item {

        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileHeaderCell.reuseIdentifier,
                for: indexPath
            ) as! ProfileHeaderCell

            cell.configure(
                name: Strings.profileName,
                image: UIImage(named: "profile_placeholder")
                    ?? UIImage(systemName: "person.crop.circle.fill")
            )
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HealthStatusCell.reuseIdentifier,
                for: indexPath
            ) as! HealthStatusCell

            cell.configure(title: Strings.healthStatusTitle)
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NotificationsHeaderCell.reuseIdentifier,
                for: indexPath
            ) as! NotificationsHeaderCell

            cell.configure(title: Strings.notificationsTitle)
            return cell

        default:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: NotificationTogglesCell.reuseIdentifier,
                for: indexPath
            )
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.bounds.width - (Layout.horizontalInset * 2)

        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: Layout.profileHeaderHeight)
        case 1:
            return CGSize(width: width, height: Layout.healthStatusHeight)
        case 2:
            return CGSize(width: width, height: Layout.notificationsHeaderHeight)
        default:
            return CGSize(width: width, height: Layout.notificationTogglesHeight)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: Layout.verticalInset,
            left: Layout.horizontalInset,
            bottom: Layout.verticalInset,
            right: Layout.horizontalInset
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.lineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard indexPath.item == 1 else { return }
        presentHealthStatus()
    }
}
