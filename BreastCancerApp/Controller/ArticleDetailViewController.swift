import UIKit

class ArticleDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var article: ArticleModel!
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
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

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

                let section = NSCollectionLayoutSection(group: group)
                return section

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

        return layout
    }

    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
