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
    }

    func goToSignUp() {
        print("goToSignUp")
        let storyboard = UIStoryboard(name: "signupMain", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "SignUpViewController"
        )
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    func login(email: String, password: String) {

        guard let profile = SampleProfilesManager.shared.sampleProfiles.first(
            where: { $0.email == email && $0.password == password }
        ) else {
            print("Invalid credentials")
            return
        }

        // FIXED: Convert UserProfile to ProfileUserProfile and save to UserProfileDataSource
        convertAndSaveProfile(profile)
        
        // Update garden stats
//        HomeDataStore.shared.gardenStats =
//            SampleProfilesManager.shared.getStatsForProfile(id: profile.id)
        
        // Set login flag
        UserDefaults.standard.set(true, forKey: "isLoggedIn")

        navigateToHome()
    }
    
    // MARK: - Profile Conversion Helper
    private func convertAndSaveProfile(_ loginProfile: UserProfile) {
        // Extract first and last name
        let nameParts = loginProfile.name.split(separator: " ")
        let firstName = nameParts.first.map(String.init) ?? "User"
        let lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
        
        // Format dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        let diagnosisDateString = loginProfile.diagnosisDate.map { dateFormatter.string(from: $0) } ?? "NA"
        let treatmentCompletionDateString = loginProfile.treatmentCompletionDate.map { dateFormatter.string(from: $0) } ?? ""
        
        // Determine age from currentAge string
        let age = extractAge(from: loginProfile.currentAge)
        
        // Map treatment status to treatment state
        let treatmentState = mapTreatmentStatus(loginProfile.treatmentStatus)
        
        // Create ProfileUserProfile
        let profileUserProfile = ProfileUserProfile(
            firstName: firstName,
            lastName: lastName,
            profileImage: nil, // Profile image can be loaded separately if needed
            diagnosisDate: diagnosisDateString,
            gender: "Female", // Default value, can be extracted if available in UserProfile
            age: age,
            cancerStage: loginProfile.currentStage ?? "NA",
            treatmentState: treatmentState,
            treatmentCompletionDate: treatmentCompletionDateString,
            exerciseNotificationsEnabled: false,
            hydrationNotificationsEnabled: false,
            appointmentsNotificationsEnabled: false,
            medicationsNotificationsEnabled: false
        )
        
        // Save to UserProfileDataSource
        UserProfileDataSource.shared.updateProfile(profileUserProfile)
        
        print("✅ Profile converted and saved for login user: \(firstName)")
    }
    
    // Helper: Extract age from age range string
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
    
    // Helper: Map treatment status to treatment state
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
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SocialLoginCollectionViewCell",
                for: indexPath
            ) as! SocialLoginCollectionViewCell
            
            cell.onSignUpTapped = { [weak self] in
                self?.goToSignUp()
            }
            
            return cell
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
