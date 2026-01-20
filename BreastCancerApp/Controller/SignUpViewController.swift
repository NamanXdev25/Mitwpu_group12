import UIKit

final class SignUpViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Section Model
    enum SignUpItem {
        case header
        case form
        case or
        case social
    }

    // MARK: - Data Order (matches Figma)
    private let items: [SignUpItem] = [
        .header,
        .form,
        .or,
        .social
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        registerCells()
    }

    // MARK: - CollectionView Setup
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)

        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    // MARK: - Cell Registration
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
            UINib(nibName: "SignUpSocialCell", bundle: nil),
            forCellWithReuseIdentifier: "SignUpSocialCell"
        )
    }
}

// MARK: - UICollectionViewDataSource
extension SignUpViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = items[indexPath.item]

        switch item {

        case .header:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpHeaderCell",
                for: indexPath
            )

        case .form:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpFormCell",
                for: indexPath
            )

        case .or:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpOrCell",
                for: indexPath
            )

        case .social:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpSocialCell",
                for: indexPath
            )
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SignUpViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let screenWidth = collectionView.bounds.width

        // Explicit pixel-driven heights (Figma-matched)
        switch items[indexPath.item] {

        case .header:
            return CGSize(width: screenWidth, height: 180)

        case .form:
            return CGSize(width: screenWidth, height: 360)

        case .or:
            return CGSize(width: screenWidth, height: 40)

        case .social:
            return CGSize(width: screenWidth, height: 220)
        }
    }
}
