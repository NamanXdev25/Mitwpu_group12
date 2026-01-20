import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataStore = HomeDataStore.shared
    
    var upcomingEvents: [HomeUpcomingModel] = []
    var memories: [HomeMemoryModel] = []
    var articles: [ArticleModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load data (upcoming, memories, articles)
        loadDataFromStore()
        
        // setup collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createCompositionalLayout()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // refresh data when view appears
        loadDataFromStore()
    }
    
    
    func loadDataFromStore() {
        upcomingEvents = dataStore.getUpcomingEvents()
        memories = dataStore.getMemories()
        
        // load articles and display first 2
        let articlesDataSource = ArticlesDataSource()
        articlesDataSource.loadArticles()
        articles = Array(articlesDataSource.articles.prefix(2))
        
        collectionView.reloadData()
    }
    
    func registerCells() {
        // register cells
        collectionView.register(UINib(nibName: "HomeHeaderCell", bundle: nil), forCellWithReuseIdentifier: "HomeHeaderCell")
        collectionView.register(UINib(nibName: "HomeHealingGardenCell", bundle: nil), forCellWithReuseIdentifier: "HomeHealingGardenCell")
        collectionView.register(UINib(nibName: "HomeUpcomingCell", bundle: nil), forCellWithReuseIdentifier: "HomeUpcomingCell")
        collectionView.register(UINib(nibName: "HomeMemoryCell", bundle: nil), forCellWithReuseIdentifier: "HomeMemoryCell")
        collectionView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellWithReuseIdentifier: "ArticleCell")
        
        collectionView.register(UINib(nibName: "HomeSectionHeaderView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HomeSectionHeaderView")
    }

    
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createHomeHeaderSection()
            case 1: return self.createGardenSection()
            case 3: return self.createUpcomingSection()
            case 4: return self.createMemoriesSection()
            case 5: return self.createArticlesSection()
            default: return nil
            }
        }
    }

    
    func createHomeHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }

    func createGardenSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(130))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    func createUpcomingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(110))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        addHeader(to: section)
        return section
    }

    func createMemoriesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(218), heightDimension: .absolute(236))
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(700), heightDimension: .absolute(236))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        group.interItemSpacing = .fixed(15)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)
        addHeader(to: section)
        return section
    }

    func createArticlesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(270))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0)
        addHeader(to: section)
        return section
    }
    
    func addHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 1
        case 3: return upcomingEvents.count
        case 4: return memories.count
        case 5: return articles.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeHeaderCell", for: indexPath) as! HomeHeaderCell
            cell.configure(name: dataStore.userProfile.name)
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeHealingGardenCell", for: indexPath) as! HomeHealingGardenCell
            let stats = dataStore.gardenStats
            cell.currentProgressLabel?.text = "\(stats.currentPoints)"
            cell.pointsLabel?.text = "\(stats.pointsToNextLevel)"
            cell.levelLabel?.text = "to Level \(stats.nextLevel)"
            cell.progressView?.progress = stats.progress
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeUpcomingCell", for: indexPath) as! HomeUpcomingCell
            let data = upcomingEvents[indexPath.row]
            cell.configure(with: data)
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMemoryCell", for: indexPath) as! HomeMemoryCell
            let data = memories[indexPath.row]
            cell.configure(with: data)
            return cell
            
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
            let data = articles[indexPath.row]
            cell.configure(with: data)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeSectionHeaderView", for: indexPath) as! HomeSectionHeaderView
        header.seeAllButton.isHidden = false
        header.seeAllButton.setTitle("See All", for: .normal)
        header.seeAllButton.tag = indexPath.section
        header.seeAllButton.addTarget(self, action: #selector(seeAllTapped(_:)), for: .touchUpInside)
        
        switch indexPath.section {
        case 3:
            header.titleLabel.text = "Upcoming Appointment"
            header.seeAllButton.isHidden = true
        case 4:
            header.titleLabel.text = "Your Memories"
        case 5:
            header.titleLabel.text = "Articles"
        default: break
        }
        return header
    }
    
    @objc func seeAllTapped(_ sender: UIButton) {
        if sender.tag == 5 { // articles section
            navigateToArticles()
        }
    }
    
    func navigateToArticles() {
        let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
        if let articlesVC = storyboard.instantiateViewController(withIdentifier: "ArticlesViewController") as? ArticlesViewController {
            navigationController?.pushViewController(articlesVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 4:
            print("Tapped memory: \(memories[indexPath.row].description)")
            // Navigate to memory details
            
        case 5:
            let article = articles[indexPath.row]
            let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ArticleDetailViewController") as? ArticleDetailViewController {
                detailVC.article = article
                
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
