import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        registerCells()
    }

    // MARK: - Setup
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: "ProfileHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: ProfileHeaderCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: "HealthStatusCell", bundle: nil),
            forCellWithReuseIdentifier: HealthStatusCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: "NotificationsHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: NotificationsHeaderCell.reuseIdentifier
        )

        collectionView.register(
            UINib(nibName: "NotificationTogglesCell", bundle: nil),
            forCellWithReuseIdentifier: NotificationTogglesCell.reuseIdentifier
        )
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Profile Header + Health Status + Notifications Header + Toggles
        return 4
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
                name: "Sophie Chen",
                image: UIImage(named: "profile_placeholder")
                    ?? UIImage(systemName: "person.crop.circle.fill")
            )
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HealthStatusCell.reuseIdentifier,
                for: indexPath
            ) as! HealthStatusCell

            cell.configure(title: "Health Status")
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NotificationsHeaderCell.reuseIdentifier,
                for: indexPath
            ) as! NotificationsHeaderCell

            cell.configure(title: "Notifications")
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

        let width = collectionView.bounds.width - 32

        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: 160) // Profile header
        case 1:
            return CGSize(width: width, height: 72)  // Health status
        case 2:
            return CGSize(width: width, height: 20)  // Notifications header (tight)
        default:
            return CGSize(width: width, height: 208) // Notification toggles
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 1 {
            let storyboard = UIStoryboard(name: "profile", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "HealthStatusViewController"
            ) as! HealthStatusViewController

            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen

            present(navController, animated: true)
        }
    }
}
