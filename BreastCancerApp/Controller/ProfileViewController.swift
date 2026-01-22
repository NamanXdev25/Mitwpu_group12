import UIKit

final class ProfileViewController: UIViewController,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Data source reference
    private let dataSource = UserProfileDataSource.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        // Setup close button action
        setupNavigationBar()

        // Register cells
        [
            (ProfileHeaderCell.reuseIdentifier, "ProfileHeaderCell"),
            (HealthStatusCell.reuseIdentifier, "HealthStatusCell"),
            (NotificationsHeaderCell.reuseIdentifier, "NotificationsHeaderCell"),
            (NotificationTogglesCell.reuseIdentifier, "NotificationTogglesCell")
        ].forEach {
            collectionView.register(
                UINib(nibName: $0.1, bundle: nil),
                forCellWithReuseIdentifier: $0.0
            )
        }

        // Listen for profile updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileDidUpdate),
            name: UserProfileDataSource.profileDidUpdateNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show close button only on this screen (not on pushed screens)
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem?.target = self
            navigationItem.leftBarButtonItem?.action = #selector(closeTapped)
        }
        
        // Reload data to show latest profile information
        collectionView.reloadData()
        
        print("📱 Profile screen appeared - displaying latest data")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Navigation Bar Setup
    
    private func setupNavigationBar() {
        // The close button is already in the storyboard
        // We just need to connect its action
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(closeTapped)
        
        // Ensure the close button only appears on the root view controller
        // This prevents it from showing on pushed view controllers
        navigationItem.hidesBackButton = false
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func profileDidUpdate() {
        print("🔄 Profile updated - reloading collection view")
        collectionView.reloadData()
    }

    // MARK: - CollectionView DataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        let profile = dataSource.userProfile

        switch indexPath.item {

        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileHeaderCell.reuseIdentifier,
                for: indexPath
            ) as! ProfileHeaderCell

            cell.configure(
                name: profile.fullName,
                image: profile.profileImage
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
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NotificationTogglesCell.reuseIdentifier,
                for: indexPath
            ) as! NotificationTogglesCell

            cell.configure(
                exerciseEnabled: profile.exerciseNotificationsEnabled,
                hydrationEnabled: profile.hydrationNotificationsEnabled,
                appointmentsEnabled: profile.appointmentsNotificationsEnabled,
                medicationsEnabled: profile.medicationsNotificationsEnabled
            )
            return cell
        }
    }

    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32

        switch indexPath.item {
        case 0: return CGSize(width: width, height: 160)
        case 1: return CGSize(width: width, height: 72)
        case 2: return CGSize(width: width, height: 20)
        default: return CGSize(width: width, height: 193)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }

    // MARK: - Navigation

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard indexPath.item == 1 else { return }

        let storyboard = UIStoryboard(name: "profile", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "HealthStatusViewController"
        ) as! HealthStatusViewController

        // Push onto the existing navigation stack (within the modal)
        navigationController?.pushViewController(vc, animated: true)
    }
}
