import UIKit

final class SignUpViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

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
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionView.setCollectionViewLayout(layout, animated: false)
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
            UINib(nibName: "SocialLoginCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SocialLoginCollectionViewCell"
        )
    }
    
    // MARK: - Navigation
    private func navigateToProfileSetup() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        guard let profileSetupVC = storyboard.instantiateViewController(
            withIdentifier: "ProfileSetupViewController"
        ) as? ProfileSetupViewController else {
            print("❌ Failed to instantiate ProfileSetupViewController")
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
            
            // Set delegate
            cell.delegate = self
            return cell

        case .or:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpOrCell",
                for: indexPath
            )

        case .social:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SocialLoginCollectionViewCell",
                for: indexPath
            )
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

// MARK: - SignUpFormCellDelegate
extension SignUpViewController: SignUpFormCellDelegate {
    
    func signUpFormCellDidTapSignUp(_ cell: SignUpFormCell, email: String, password: String, reenterPassword: String, agreedToTerms: Bool) {
        
        print("✅ Sign Up Data:")
        print("Email: \(email)")
        print("Password: \(password)")
        print("Agreed to Terms: \(agreedToTerms)")
        
        // Here you can add your sign-up logic (API call, Firebase, etc.)
        // For now, we'll just navigate to ProfileSetup
        
        navigateToProfileSetup()
    }
}
