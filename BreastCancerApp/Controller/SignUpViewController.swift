import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Cell Types
    enum SignUpItem {
        case header
        case form
        case or
        case social
    }

    // MARK: - Data Source Order
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

    // MARK: - Setup
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero
        }
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

        switch items[indexPath.item] {

        case .header:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpHeaderCell",
                for: indexPath
            ) as! SignUpHeaderCell

        case .form:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpFormCell",
                for: indexPath
            ) as! SignUpFormCell

        case .or:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpOrCell",
                for: indexPath
            ) as! SignUpOrCell

        case .social:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "SignUpSocialCell",
                for: indexPath
            ) as! SignUpSocialCell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SignUpViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width

        switch items[indexPath.item] {

        case .header:
            return CGSize(width: width, height: 160)

        case .form:
            return CGSize(width: width, height: 540)

        case .or:
            return CGSize(width: width, height: 44)

        case .social:
            return CGSize(width: width, height: 220)
        }
    }
}
