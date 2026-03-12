import UIKit

class MindfulnessViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!

    var dataSource: MindfulnessDataSource!

    // MARK: - Sections
    enum Section: Int, CaseIterable {
        case positiveMomentsHeader
        case memories
        case explore
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = MindfulnessDataSource(viewController: self)
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        registerCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reloadMemories()
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.reloadData()
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
            UINib(nibName: "MemoryEmptyStateCell", bundle: nil),
            forCellWithReuseIdentifier: "MemoryEmptyStateCell"
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
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        let hasMemories = !dataSource.memories.isEmpty

        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {

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
                    top: 16, leading: 16, bottom: 8, trailing: 8
                )
                return section

            case .memories:
                if !hasMemories {
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(160)
                        )
                    )
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(160)
                        ),
                        subitems: [item]
                    )
                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = .init(top: 0, leading: 16, bottom: 24, trailing: 16)
                    return section
                }

                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .absolute(220),
                        heightDimension: .estimated(260)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .absolute(220),
                        heightDimension: .estimated(260)
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = .init(top: 0, leading: 8, bottom: 24, trailing: 8)
                return section

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
                    top: 0, leading: 0, bottom: 12, trailing: 0
                )
                return section
            }
        }
    }

    // MARK: - Navigation Helper
    func navigateToBreathingViewController() {
        let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
        if let breathingVC = storyboard.instantiateViewController(withIdentifier: "BreathingViewController") as? BreathingViewController {
            navigationController?.pushViewController(breathingVC, animated: true)
        }
    }
}

extension MindfulnessViewController: UICollectionViewDelegate {}
