import UIKit

class ArticleDetailViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    // swiftlint:disable:next implicitly_unwrapped_optional
    var article: ArticleModel!
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var dataSource: ArticleDetailDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()

        dataSource = ArticleDetailDataSource(article: article)
        collectionView.dataSource = dataSource

        collectionView.register(
            UINib(nibName: "ArticleHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "ArticleHeaderCell"
        )
        collectionView.register(
            UINib(nibName: "ArticleContentCell", bundle: nil),
            forCellWithReuseIdentifier: "ArticleContentCell"
        )
        collectionView.register(
            UINib(nibName: "ArticleImageCell", bundle: nil),
            forCellWithReuseIdentifier: "ArticleImageCell"
        )
        collectionView.register(
            UINib(nibName: "ArticleLinkCell", bundle: nil),
            forCellWithReuseIdentifier: "ArticleLinkCell"
        )
    }

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(200)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(200)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                return NSCollectionLayoutSection(group: group)

            } else {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(500)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(500)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 0,
                    trailing: 16
                )

                return section
            }
        }
    }

    @IBAction func closeTapped(_: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
