import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var HomeCollectionView: UICollectionView!
    @IBOutlet weak var ProfileButton: UIBarButtonItem!
    
    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setupCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    @IBAction func ProfileButtonTapped(_ sender: Any) {
        print("👆 Profile button tapped")
    }
    
    // MARK: - Register Cells
    private func registerCells() {
        let cellIdentifiers = [
            "HomeQuoteCell",
            "HomeMoodCell",
            "HomeSuggestionCell",
            "HomeArticleCell"
        ]
        
        for identifier in cellIdentifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            HomeCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
        
        let headerNib = UINib(nibName: "HomeHeaderCell", bundle: nil)
        HomeCollectionView.register(
            headerNib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HomeHeaderCell"
        )
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
        HomeCollectionView.delegate = self
        HomeCollectionView.backgroundColor = UIColor(named: "logsbgcolor") ?? .systemBackground
        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    // MARK: - Create Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let sectionType = HomeSectionType(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .title:
                return self.createEmptySection()
            case .quote:        return self.createQuoteSection()
            case .mood:         return self.createMoodSection()
            case .suggestion:   return self.createSuggestionSection()
            case .articles:     return self.createArticlesSection()
            }
        }
    }
    
    // MARK: - Section Layouts
    
    private func createEmptySection() -> NSCollectionLayoutSection {
        let itemSize   = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let item       = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let group      = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section    = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }
    
    private func createQuoteSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16)
        
        return section
    }
    
    private func createMoodSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(155)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(155)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        return section
    }
    
    private func createSuggestionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(116)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(116)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 12
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(52)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createArticlesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(273)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(273)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16)
        section.interGroupSpacing = 12
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(52)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // MARK: - Configure Data Source
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(
            collectionView: HomeCollectionView
        ) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            switch item.type {
            case .title:
                return UICollectionViewCell()
                
            case .quote(let quote):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeQuoteCell",
                    for: indexPath
                ) as! HomeQuoteCell
                cell.configure(quote: quote)
                return cell
                
            case .mood:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeMoodCell",
                    for: indexPath
                ) as! HomeMoodCell
                cell.configure(title: "How are you feeling right now?", moods: HomeModel.moods)
                return cell
                
            case .suggestion(let suggestion):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeSuggestionCell",
                    for: indexPath
                ) as! HomeSuggestionCell
                cell.configure(with: suggestion)
                return cell
                
            case .article(let article):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeArticleCell",
                    for: indexPath
                ) as! HomeArticleCell
                cell.configure(with: article)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HomeHeaderCell",
                for: indexPath
            ) as! HomeHeaderCell
            
            guard let sectionType = HomeSectionType(rawValue: indexPath.section) else { return header }
            
            switch sectionType {
            case .suggestion:
                header.configure(title: "Suggested For You", showSeeAll: false)
            case .articles:
                header.configure(title: "Articles", showSeeAll: true)
                header.onSeeAllTapped = { [weak self] in
                    self?.navigateToArticles()
                }
            default:
                break
            }
            
            return header
        }
    }
    
    // MARK: - Apply Snapshot
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
        
        snapshot.appendSections(HomeSectionType.allCases)
        
        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)
        
        let suggestionItems = HomeModel.suggestions.map { HomeItem(type: .suggestion($0)) }
        snapshot.appendItems(suggestionItems, toSection: .suggestion)
        
        let articleItems = HomeModel.articles.map { HomeItem(type: .article($0)) }
        snapshot.appendItems(articleItems, toSection: .articles)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Navigation
    func navigateToArticles() {
        let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
        if let articlesVC = storyboard.instantiateViewController(withIdentifier: "ArticlesViewController") as? ArticlesViewController {
            navigationController?.pushViewController(articlesVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegate
// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item.type {
        case .suggestion(let suggestion):
            print("👆 Selected suggestion: \(suggestion.title)")
            
        case .article(let article):
            print("👆 Selected article: \(article.title)")
            
            // Find the matching article from ArticlesDataSource
            let articlesDataSource = ArticlesDataSource()
            articlesDataSource.loadArticles()
            
            // Find article by title match
            guard let fullArticle = articlesDataSource.articles.first(where: { $0.title == article.title }) else {
                print("⚠️ Could not find full article details")
                return
            }
            
            // Open article modally
            let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ArticleDetailViewController") as? ArticleDetailViewController {
                detailVC.article = fullArticle
                
                let navController = UINavigationController(rootViewController: detailVC)
                if let sheet = navController.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                }
                present(navController, animated: true)
            }
            
        default:
            break
        }
    }
}
