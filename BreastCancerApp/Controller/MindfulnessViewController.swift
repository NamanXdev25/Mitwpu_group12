import UIKit

class MindfulnessViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!

    private var dataSource: MindfulnessDataSource!

    // MARK: - Sections
    enum Section: Int, CaseIterable {
        case positiveMomentsHeader
        case memories
        case explore
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation title (replaces old static label)
        title = "Mindfulness"

        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.delegate = self

        dataSource = MindfulnessDataSource(viewController: self)
        collectionView.dataSource = dataSource

        registerCells()
    }

    // MARK: - Cell Registration
    private func registerCells() {

        collectionView.register(
            UINib(nibName: "PositiveMomentsHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "PositiveMomentsHeaderCell"
        )

        collectionView.register(
            UINib(nibName: "HomeMemoryCell", bundle: nil),
            forCellWithReuseIdentifier: "HomeMemoryCell"
        )

        collectionView.register(
            UINib(nibName: "MindfulnessExploreLabelCell", bundle: nil),
            forCellWithReuseIdentifier: "MindfulnessExploreLabelCell"
        )

        collectionView.register(
            UINib(nibName: "MindfulnessExploreCell", bundle: nil),
            forCellWithReuseIdentifier: "MindfulnessExploreCell"
        )
    }

    // MARK: - Layout
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {

            // 🔹 Positive Moments header (FULL WIDTH, STATIC HEIGHT)
            case .positiveMomentsHeader:
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    )
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    ),
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 16,
                    leading: 16,
                    bottom: 8,
                    trailing: 16
                )
                return section

            // 🔹 Memory cards (HORIZONTAL — DO NOT TOUCH)
            case .memories:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .absolute(220),
                        heightDimension: .estimated(260)
                    )
                )

                // ✅ 8pt space BETWEEN cards
                item.contentInsets = .init(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .absolute(220), // 🔥 KEY FIX
                        heightDimension: .estimated(260)
                    ),
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous

                // ✅ 8pt padding at START and END of scroll
                section.contentInsets = .init(
                    top: 0,
                    leading: 8,
                    bottom: 24,
                    trailing: 8
                )

                return section
            // 🔹 Explore section (UNCHANGED)
            case .explore:
                let labelItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )

                let cardItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(116)
                    )
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(300)
                    ),
                    subitems: [labelItem, cardItem, cardItem]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 12,
                    trailing: 0
                )
                return section
            }
        }
    }
}

extension MindfulnessViewController: UICollectionViewDelegate {}
