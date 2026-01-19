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

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true

        collectionView.keyboardDismissMode = .interactive
        collectionView.backgroundColor = .white

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
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "FormCollectionViewCell",
                for: indexPath
            ) as! FormCollectionViewCell

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
            return CGSize(width: width, height: 140)

        case .form:
            return CGSize(width: width, height: 420)

        case .or:
            return CGSize(width: width, height: 44)

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
