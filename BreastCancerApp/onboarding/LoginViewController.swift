import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    private let authService = SupabaseAuthService.shared

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
        .social,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func goToSignUp() {
        let storyboard = UIStoryboard(name: "signupMain", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "SignUpViewController"
        )

        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    func login(email: String, password: String) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, !trimmedPassword.isEmpty else {
            showAuthAlert(message: "Please enter both email and password.")
            return
        }

        if AppBackend.current == .supabase {
            loginWithSupabase(email: normalizedEmail, password: trimmedPassword)
            return
        }

        guard let profile = SampleProfilesManager.shared.sampleProfiles.first(
            where: { $0.email == normalizedEmail && $0.password == trimmedPassword }
        ) else {
            showAuthAlert(message: "Invalid email or password.")
            return
        }

        convertAndSaveProfile(profile)
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        navigateToHome()
    }

    private func loginWithSupabase(email: String, password: String) {
        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .failure(error):
                    self.showAuthAlert(message: error.localizedDescription)
                case let .success(user):
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(user.has_completed_onboarding, forKey: "hasCompletedOnboarding")
                    
                    RepositoryFactory.reset()
                    
                    self.syncProfileAfterSupabaseLogin(user: user) {
                        SyncManager.shared.pullAllImmediately {
                            if user.has_completed_onboarding {
                                self.navigateToHome()
                            } else {
                                self.navigateToProfileSetup()
                            }
                        }
                    }
                }
            }
        }
    }

    private func loginWithGoogle() {
        guard AppBackend.current == .supabase else {
            showAuthAlert(message: "Google auth is currently enabled only for Supabase mode.")
            return
        }

        authService.signInWithGoogleNative(presentingViewController: self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .failure(error):
                    if case .oauthCancelled = error { return }
                    self.showAuthAlert(message: error.localizedDescription)
                case let .success(user):
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(user.has_completed_onboarding, forKey: "hasCompletedOnboarding")
                    
                    RepositoryFactory.reset()
                    
                    self.syncProfileAfterSupabaseLogin(user: user) {
                        SyncManager.shared.pullAllImmediately {
                            if user.has_completed_onboarding {
                                self.navigateToHome()
                            } else {
                                self.navigateToProfileSetup()
                            }
                        }
                    }
                }
            }
        }
    }

    private func syncProfileAfterSupabaseLogin(user: AuthUserSupabaseRow, completion: @escaping () -> Void) {
        SupabaseRESTClient.shared.fetchRows(
            from: "user_profiles",
            filters: [SupabaseFilter(key: "user_id", op: "eq", value: user.user_id.uuidString)]
        ) { (rows: [UserProfileSupabaseRow]) in
            DispatchQueue.main.async {
                if let row = rows.first {
                    UserProfileDataSource.shared.updateProfile(ProfileUserProfile(supabaseRow: row))
                    completion()
                    return
                }

                let firstName = user.email.split(separator: "@").first.map(String.init)?.capitalized ?? "User"
                let fallback = ProfileUserProfile(
                    firstName: firstName,
                    lastName: "",
                    profileImageBase64: nil,
                    diagnosisDate: "NA",
                    gender: "Female",
                    age: 32,
                    cancerStage: "NA",
                    treatmentState: "Unknown",
                    treatmentCompletionDate: "",
                    exerciseNotificationsEnabled: false,
                    hydrationNotificationsEnabled: false,
                    appointmentsNotificationsEnabled: false,
                    medicationsNotificationsEnabled: false
                )
                UserProfileDataSource.shared.updateProfile(fallback)
                completion()
            }
        }
    }

    // MARK: - Profile Conversion Helper

    private func convertAndSaveProfile(_ loginProfile: UserProfile) {
        let nameParts = loginProfile.name.split(separator: " ")
        let firstName = nameParts.first.map(String.init) ?? "User"
        let lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"

        let diagnosisDateString = loginProfile.diagnosisDate.map { dateFormatter.string(from: $0) } ?? "NA"
        let treatmentCompletionDateString = loginProfile.treatmentCompletionDate.map { dateFormatter.string(from: $0) } ?? ""

        let age = extractAge(from: loginProfile.currentAge)

        let treatmentState = mapTreatmentStatus(loginProfile.treatmentStatus)

        let profileUserProfile = ProfileUserProfile(
            firstName: firstName,
            lastName: lastName,
            profileImage: nil,
            diagnosisDate: diagnosisDateString,
            gender: "Female",
            age: age,
            cancerStage: loginProfile.currentStage ?? "NA",
            treatmentState: treatmentState,
            treatmentCompletionDate: treatmentCompletionDateString,
            exerciseNotificationsEnabled: false,
            hydrationNotificationsEnabled: false,
            appointmentsNotificationsEnabled: false,
            medicationsNotificationsEnabled: false
        )

        UserProfileDataSource.shared.updateProfile(profileUserProfile)
    }

    private func extractAge(from ageString: String?) -> Int {
        guard let ageString = ageString else { return 32 }

        if ageString.contains("-") {
            let components = ageString.split(separator: "-")
            if components.count == 2,
               let lowerBound = Int(components[0]),
               let upperBound = Int(components[1]) {
                return (lowerBound + upperBound) / 2
            }
        }

        if ageString.lowercased().contains("below 18") {
            return 16
        }
        if ageString.contains("75+") {
            return 77
        }
        return 32
    }

    private func mapTreatmentStatus(_ status: String) -> String {
        switch status {
        case "Currently in treatment":
            return "Ongoing"
        case "Under Observation":
            return "Observation"
        case "Post-treatment / in recovery":
            return "Completed"
        case "Prefer not to say":
            return "Not Specified"
        default:
            return "Unknown"
        }
    }

    func navigateToHome() {
        let storyboard = UIStoryboard(name: "TabbarMain", bundle: nil)

        guard let tabBarController =
            storyboard.instantiateInitialViewController()
                as? UITabBarController
        else {
            fatalError("TabBarMain must have UITabBarController as initial VC")
        }

        if let sceneDelegate =
            UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    private func navigateToProfileSetup() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)

        guard let profileSetupVC = storyboard.instantiateViewController(
            withIdentifier: "ProfileSetupViewController"
        ) as? ProfileSetupViewController else {
            showAuthAlert(message: "Could not open profile setup.")
            return
        }

        profileSetupVC.modalPresentationStyle = .fullScreen
        profileSetupVC.modalTransitionStyle = .crossDissolve
        present(profileSetupVC, animated: true)
    }

    private func showAuthAlert(message: String) {
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true

        collectionView.keyboardDismissMode = .onDrag
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
    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection _: Int
    ) -> Int {
        return items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch items[indexPath.item] {
        case .welcome:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "WelcomeHeaderCollectionViewCell",
                for: indexPath
            ) as? WelcomeHeaderCollectionViewCell else {
                fatalError("Expected WelcomeHeaderCollectionViewCell for reuse identifier 'WelcomeHeaderCollectionViewCell' at \(indexPath)")
            }
            cell.titleLabel.text = "Welcome Back"
            cell.subtitleLabel.text = "Login to your account"
            return cell

        case .form:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "FormCollectionViewCell",
                for: indexPath
            ) as? FormCollectionViewCell else {
                fatalError("Expected FormCollectionViewCell for reuse identifier 'FormCollectionViewCell' at \(indexPath)")
            }

            cell.onLoginTapped = { [weak self] email, password in
                self?.login(email: email, password: password)
            }

            return cell

        case .or:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "OrSeparatorCollectionViewCell",
                for: indexPath
            ) as? OrSeparatorCollectionViewCell else {
                fatalError("Expected OrSeparatorCollectionViewCell for reuse identifier 'OrSeparatorCollectionViewCell' at \(indexPath)")
            }
            return cell

        case .social:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SocialLoginCollectionViewCell",
                for: indexPath
            ) as? SocialLoginCollectionViewCell else {
                fatalError("Expected SocialLoginCollectionViewCell for reuse identifier 'SocialLoginCollectionViewCell' at \(indexPath)")
            }

            cell.onSignUpTapped = { [weak self] in
                self?.goToSignUp()
            }
            cell.onGoogleTapped = { [weak self] in
                self?.loginWithGoogle()
            }

            return cell
        }
    }
}

// MARK: - Layout

extension LoginViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
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

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        return 0
    }
}
