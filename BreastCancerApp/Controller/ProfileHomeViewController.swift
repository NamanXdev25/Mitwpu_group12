//
//  ProfileHomeViewController.swift
//  BreastCancerApp
//

import UIKit

class ProfileHomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var notifications = NotificationItem.defaultItems()

    // Always reads from the shared store
    private var profile: UserProfile { UserProfileStore.shared.profile }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor             = UIColor(named: "AppBackground") ?? .systemBackground
        collectionView.backgroundColor   = UIColor(named: "AppBackground") ?? .systemBackground
        collectionView.dataSource        = self
        collectionView.delegate          = self
        registerCells()

        // Refresh when health status screen saves changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileDidChange),
            name: UserProfileStore.profileDidChangeNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Also refresh every time we come back to this screen
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }

    @objc private func profileDidChange() {
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerCells() {
        collectionView.register(UINib(nibName: "ProfileHeaderCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProfileHeaderCell")
        collectionView.register(UINib(nibName: "MenuOptionCell", bundle: nil),
                                forCellWithReuseIdentifier: "MenuOptionCell")
        collectionView.register(UINib(nibName: "SectionTitleCell", bundle: nil),
                                forCellWithReuseIdentifier: "SectionTitleCell")
        collectionView.register(UINib(nibName: "NotificationGroupCell", bundle: nil),
                                forCellWithReuseIdentifier: "NotificationGroupCell")
    }
}

extension ProfileHomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { 5 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.item {

        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileHeaderCell", for: indexPath) as! ProfileHeaderCell
            // Always uses latest profile from store
            cell.configure(
                name: "\(profile.firstName) \(profile.lastName)",
                image: profile.profileImage
            )
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MenuOptionCell", for: indexPath) as! MenuOptionCell
            cell.configure(title: "Health Status")
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MenuOptionCell", for: indexPath) as! MenuOptionCell
            cell.configure(title: "Self Exam")
            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SectionTitleCell", for: indexPath) as! SectionTitleCell
            return cell

        case 4:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "NotificationGroupCell", for: indexPath) as! NotificationGroupCell
            cell.configure(notifications: notifications)
            return cell

        default:
            return UICollectionViewCell()
        }
    }
}

extension ProfileHomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0: return CGSize(width: collectionView.frame.width, height: 180)
        case 3: return CGSize(width: collectionView.frame.width, height: 60)
        case 4: return CGSize(width: collectionView.frame.width, height: 220)
        default: return CGSize(width: collectionView.frame.width, height: 70)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 12 }
}

extension ProfileHomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 1:
            let vc = storyboard?.instantiateViewController(
                withIdentifier: "HealthStatusViewController") as! HealthStatusViewController
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = storyboard?.instantiateViewController(
                withIdentifier: "SelfExamViewController") as! SelfExamViewController
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
}
