import UIKit

final class SignUpViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let authService = SupabaseAuthService.shared

    enum SignUpItem {
        case header
        case form
        case or
        case social
    }

    private let items: [SignUpItem] = [
        .header,
        .form,
        .or,
        .social
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        registerCells()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 40,
            right: 0
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.keyboardDismissMode = .onDrag
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: "SignUpHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "SignUpHeaderCell"
        )

        collectionView.register(
            UINib(nibName: "SignUpFormCell", bundle: nil),
            forCellWithReuseIdentifier: "SignUpFormCell"
        )

        collectionView.register(
            UINib(nibName: "SignUpOrCell", bundle: nil),
            forCellWithReuseIdentifier: "SignUpOrCell"
        )

        collectionView.register(
            UINib(nibName: "SocialSignupCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SocialSignupCollectionViewCell"
        )
    }
    
    // MARK: - Navigation
    private func navigateToProfileSetup() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        guard let profileSetupVC = storyboard.instantiateViewController(
            withIdentifier: "ProfileSetupViewController"
        ) as? ProfileSetupViewController else {
            return
        }
        
        profileSetupVC.modalPresentationStyle = .fullScreen
        profileSetupVC.modalTransitionStyle = .crossDissolve
        present(profileSetupVC, animated: true)
    }
}

// MARK: - DataSource
extension SignUpViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch items[indexPath.item] {

        case .header:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpHeaderCell",
                for: indexPath
            )

        case .form:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpFormCell",
                for: indexPath
            ) as! SignUpFormCell
            
            cell.delegate = self
            return cell

        case .or:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpOrCell",
                for: indexPath
            )

        case .social:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SocialSignupCollectionViewCell",
                for: indexPath
            ) as! SocialSignupCollectionViewCell
            
            cell.onSignInTapped = { [weak self] in
                self?.navigateToSignIn()
            }
            cell.onGoogleTapped = { [weak self] in
                self?.signUpWithGoogle()
            }
            
            return cell
        }
    }
}

// MARK: - Layout
extension SignUpViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width

        switch items[indexPath.item] {
        case .header:
            return CGSize(width: width, height: 180)

        case .form:
            return CGSize(width: width, height: 360)

        case .or:
            return CGSize(width: width, height: 30)

        case .social:
            return CGSize(width: width, height: 240)
        }
    }
}

extension SignUpViewController: SignUpFormCellDelegate {
    
    func signUpFormCellDidTapSignUp(_ cell: SignUpFormCell, email: String, password: String, reenterPassword: String, agreedToTerms: Bool) {
        guard agreedToTerms else {
            showAuthAlert(message: "Please agree to terms and conditions.")
            return
        }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty, !trimmedPassword.isEmpty else {
            showAuthAlert(message: "Please enter email and password.")
            return
        }

        if AppBackend.current == .supabase {
            signUpWithSupabase(email: normalizedEmail, password: trimmedPassword)
            return
        }

        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        navigateToProfileSetup()
    }

    private func signUpWithSupabase(email: String, password: String) {
        authService.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .failure(let error):
                    self.showAuthAlert(message: error.localizedDescription)
                case .success(let user):
                    let firstName = user.email.split(separator: "@").first.map(String.init)?.capitalized ?? "User"
                    let newProfile = ProfileUserProfile(
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
                    UserProfileDataSource.shared.updateProfile(newProfile)
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    self.navigateToProfileSetup()
                }
            }
        }
    }

    private func signUpWithGoogle() {
        guard AppBackend.current == .supabase else {
            showAuthAlert(message: "Google auth is currently enabled only for Supabase mode.")
            return
        }

        authService.signInWithGoogleNative(presentingViewController: self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .failure(let error):
                    if case .oauthCancelled = error { return }
                    self.showAuthAlert(message: error.localizedDescription)
                case .success(let user):
                    let firstName = user.email.split(separator: "@").first.map(String.init)?.capitalized ?? "User"
                    let profile = ProfileUserProfile(
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
                    UserProfileDataSource.shared.updateProfile(profile)
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(user.has_completed_onboarding, forKey: "hasCompletedOnboarding")
                    if user.has_completed_onboarding {
                        self.navigateToHome()
                    } else {
                        self.navigateToProfileSetup()
                    }
                }
            }
        }
    }

    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "TabBarMain", bundle: nil)
        guard let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController else {
            showAuthAlert(message: "Could not open home.")
            return
        }

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    private func navigateToSignIn() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard let loginRoot = storyboard.instantiateInitialViewController() else {
            showAuthAlert(message: "Could not open sign in screen.")
            return
        }
        loginRoot.modalPresentationStyle = .fullScreen
        loginRoot.modalTransitionStyle = .crossDissolve
        present(loginRoot, animated: true)
    }

    private func showAuthAlert(message: String) {
        let alert = UIAlertController(title: "Sign Up", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
