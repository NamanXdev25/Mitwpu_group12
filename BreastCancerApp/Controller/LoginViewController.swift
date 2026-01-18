import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Cell Types (Order matters)
    private enum LoginSectionItem {
        case welcome
        case form
    }

    private let items: [LoginSectionItem] = [
        .welcome,
        .form
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

        // Register Welcome Header Cell
        collectionView.register(
            UINib(nibName: "WelcomeHeaderCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "WelcomeHeaderCollectionViewCell"
        )

        // Register Form Cell
        collectionView.register(
            UINib(nibName: "FormCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "FormCollectionViewCell"
        )
    }
}

// MARK: - UICollectionViewDataSource
extension LoginViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let item = items[indexPath.item]

        switch item {

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

            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LoginViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let item = items[indexPath.item]

        switch item {
        case .welcome:
            return CGSize(width: collectionView.frame.width, height: 140)

        case .form:
            return CGSize(width: collectionView.frame.width, height: 420)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
}
