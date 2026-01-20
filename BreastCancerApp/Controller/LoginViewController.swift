import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private enum LoginSectionItem {
        case welcome
        case form
        case or
        case social
    }

    private let items: [LoginSectionItem] = [
        .welcome,
        .form,
        .or,
        .social
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        
        // temp - auto-login for development
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.loginUser()
//        }
    }
    
    func login(email: String, password: String) {

        guard let profile = SampleProfilesManager.shared.sampleProfiles.first(
            where: { $0.email == email && $0.password == password }
        ) else {
            print("❌ Invalid credentials")
            return
        }

        HomeDataStore.shared.userProfile = profile
        HomeDataStore.shared.gardenStats =
            SampleProfilesManager.shared.getStatsForProfile(id: profile.id)

        navigateToHome()
    }
    
    func loginUser() {
        // Pick first predefined profile
        let profile = SampleProfilesManager.shared.sampleProfiles[0]

        // Set it as active user
        HomeDataStore.shared.userProfile = profile
        HomeDataStore.shared.gardenStats =
            SampleProfilesManager.shared.getStatsForProfile(id: profile.id)

        navigateToHome()
    }
    
    func navigateToHome() {
        let storyboard = UIStoryboard(name: "TabBarMain", bundle: nil)

        guard let tabBarController =
                storyboard.instantiateInitialViewController()
                as? UITabBarController else {
            fatalError("TabBarMain must have UITabBarController as initial VC")
        }

        if let sceneDelegate =
            UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }



    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true

        collectionView.keyboardDismissMode = .interactive
        collectionView.backgroundColor = .white

        collectionView.contentInset = UIEdgeInsets(
            top: 90,
            left: 0,
            bottom: 10,
            right: 0
        )

        collectionView.verticalScrollIndicatorInsets = collectionView.contentInset

        collectionView.register(
            UINib(nibName: "WelcomeHeaderCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "WelcomeHeaderCollectionViewCell"
        )

        collectionView.register(
            UINib(nibName: "FormCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "FormCollectionViewCell"
        )

        collectionView.register(
            UINib(nibName: "OrSeparatorCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "OrSeparatorCollectionViewCell"
        )

        collectionView.register(
            UINib(nibName: "SocialLoginCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SocialLoginCollectionViewCell"
        )
    }
}

// MARK: - DataSource
extension LoginViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch items[indexPath.item] {

        case .welcome:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "WelcomeHeaderCollectionViewCell",
                for: indexPath
            ) as! WelcomeHeaderCollectionViewCell
            cell.titleLabel.text = "Welcome Back"
            cell.subtitleLabel.text = "Login to your account"
            return cell

        case .form:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "FormCollectionViewCell",
                for: indexPath
            ) as! FormCollectionViewCell

            cell.onLoginTapped = { [weak self] email, password in
                self?.login(email: email, password: password)
            }

            return cell


        case .or:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "OrSeparatorCollectionViewCell",
                for: indexPath
            ) as! OrSeparatorCollectionViewCell

        case .social:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SocialLoginCollectionViewCell",
                for: indexPath
            ) as! SocialLoginCollectionViewCell
        }
    }
}

// MARK: - Layout
extension LoginViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width

        switch items[indexPath.item] {

        case .welcome:
            return CGSize(width: width, height: 120)

        case .form:
            return CGSize(width: width, height: 360)

        case .or:
            return CGSize(width: width, height: 20)

        case .social:
            return CGSize(width: width, height: 220)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
