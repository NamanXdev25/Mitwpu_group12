////
////  HomeViewController.swift
////  BreastCancerApp
////
////  Created by Naman Bhansali on 02/02/26.
////
//
//import UIKit
//
//class HomeViewController: UIViewController {
//
//    @IBOutlet weak var HomeCollectionView: UICollectionView!
//    
//    // MARK: - Properties
//    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Critical: Since you use separate XIBs, they must be registered via UINib
//        registerCells()
//        setupCollectionView()
//        configureDataSource()
//        applySnapshot()
//    }
//    
//    // MARK: - Register Cells
//    private func registerCells() {
//        // Register all cell XIBs
//        let cellIdentifiers = [
//            "HomeTitleCell",
//            "HomeQuoteCell",
//            "HomeMoodCell",
//            "HomeSuggestionCell",
//            "HomeArticleCell"
//        ]
//        
//        for identifier in cellIdentifiers {
//            let nib = UINib(nibName: identifier, bundle: nil)
//            HomeCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
//        }
//        
//        // Register Header XIB
//        let headerNib = UINib(nibName: "HomeHeaderCell", bundle: nil)
//        HomeCollectionView.register(
//            headerNib,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "HomeHeaderCell"
//        )
//    }
//    
//    // MARK: - Setup Collection View
//    private func setupCollectionView() {
//        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
//        HomeCollectionView.delegate = self
//        HomeCollectionView.backgroundColor = .systemBackground
//        
//        // Use automatic content inset adjustment for safe area
//        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
//    }
//    
//    // MARK: - Create Compositional Layout
//    private func createCompositionalLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
//            guard let sectionType = HomeSectionType(rawValue: sectionIndex) else { return nil }
//            
//            switch sectionType {
//            case .title: return self.createTitleSection()
//            case .quote: return self.createQuoteSection()
//            case .mood: return self.createMoodSection()
//            case .suggestion: return self.createSuggestionSection()
//            case .articles: return self.createArticlesSection()
//            }
//        }
//    }
//    
//    // MARK: - Section Layouts
//    
//    // Title Section (Home + Profile)
//    private func createTitleSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 20)
//        return section
//    }
//    
//    // Quote Section
//    private func createQuoteSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
//        return section
//    }
//    
//    // Mood Section
//    private func createMoodSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
//        return section
//    }
//    
//    // Suggestion Section
//    private func createSuggestionSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(110))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(110))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .groupPaging
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 24, trailing: 20)
//        section.interGroupSpacing = 12
//        section.boundarySupplementaryItems = [createHeaderItem()]
//        return section
//    }
//    
//    // Articles Section
//    private func createArticlesSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(280))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20)
//        section.interGroupSpacing = 12
//        section.boundarySupplementaryItems = [createHeaderItem()]
//        return section
//    }
//    
//    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
//        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//    }
//    
//    // MARK: - Configure Data Source
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(collectionView: HomeCollectionView) { (collectionView, indexPath, item) in
//            switch item.type {
//            case .title:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTitleCell", for: indexPath) as! HomeTitleCell
//                cell.configure(title: "Home", profileImage: UIImage(named: "profile_image"))
//                return cell
//            case .quote(let text):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeQuoteCell", for: indexPath) as! HomeQuoteCell
//                cell.configure(quote: text)
//                return cell
//            case .mood:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMoodCell", for: indexPath) as! HomeMoodCell
//                cell.configure(title: "How are you feeling right now?", moods: HomeModel.moods)
//                return cell
//            case .suggestion(let sug):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSuggestionCell", for: indexPath) as! HomeSuggestionCell
//                cell.configure(with: sug)
//                return cell
//            case .article(let art):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeArticleCell", for: indexPath) as! HomeArticleCell
//                cell.configure(with: art)
//                return cell
//            }
//        }
//        
//        dataSource.supplementaryViewProvider = { (cv, kind, indexPath) in
//            let header = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeHeaderCell", for: indexPath) as! HomeHeaderCell
//            let section = HomeSectionType(rawValue: indexPath.section)
//            header.configure(title: section == .suggestion ? "Suggested For You" : "Articles")
//            return header
//        }
//    }
//    
//    // MARK: - Apply Snapshot
//    private func applySnapshot() {
//        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
//        snapshot.appendSections(HomeSectionType.allCases)
//        
//        snapshot.appendItems([HomeItem(type: .title)], toSection: .title)
//        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
//        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)
//        
//        let suggestionItems = HomeModel.suggestions.map { HomeItem(type: .suggestion($0)) }
//        snapshot.appendItems(suggestionItems, toSection: .suggestion)
//        
//        let articleItems = HomeModel.articles.map { HomeItem(type: .article($0)) }
//        snapshot.appendItems(articleItems, toSection: .articles)
//        
//        dataSource.apply(snapshot, animatingDifferences: false)
//    }
//}
//
//extension HomeViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//        switch item.type {
//        case .suggestion(let suggestion): print("Selected suggestion: \(suggestion.title)")
//        case .article(let article): print("Selected article: \(article.title)")
//        default: break
//        }
//    }
//}


//
//  HomeViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//

//import UIKit
//
//class HomeViewController: UIViewController {
//
//    @IBOutlet weak var HomeCollectionView: UICollectionView!
//    
//    // MARK: - Properties
//    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        registerCells()
//        setupCollectionView()
//        configureDataSource()
//        applySnapshot()
//    }
//    
//    // MARK: - Register Cells
//    private func registerCells() {
//        // Try to register cells from XIB files
//        // If XIBs don't exist, cells should already be registered in Storyboard
//        let cellIdentifiers = [
//            "HomeTitleCell",
//            "HomeQuoteCell",
//            "HomeMoodCell",
//            "HomeSuggestionCell",
//            "HomeArticleCell"
//        ]
//        
//        for identifier in cellIdentifiers {
//            // Try to load XIB, if it fails, assume it's registered in Storyboard
//            if let _ = Bundle.main.path(forResource: identifier, ofType: "nib") {
//                let nib = UINib(nibName: identifier, bundle: nil)
//                HomeCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
//            }
//        }
//        
//        // Try to register header from XIB
//        if let _ = Bundle.main.path(forResource: "HomeHeaderCell", ofType: "nib") {
//            let headerNib = UINib(nibName: "HomeHeaderCell", bundle: nil)
//            HomeCollectionView.register(
//                headerNib,
//                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                withReuseIdentifier: "HomeHeaderCell"
//            )
//        }
//    }
//    
//    // MARK: - Setup Collection View
//    private func setupCollectionView() {
//        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
//        HomeCollectionView.delegate = self
//        HomeCollectionView.backgroundColor = .systemBackground
//        
//        // Use automatic content inset adjustment for safe area
//        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
//    }
//    
//    // MARK: - Create Compositional Layout
//    private func createCompositionalLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
//            guard let sectionType = HomeSectionType(rawValue: sectionIndex) else { return nil }
//            
//            switch sectionType {
//            case .title: return self.createTitleSection()
//            case .quote: return self.createQuoteSection()
//            case .mood: return self.createMoodSection()
//            case .suggestion: return self.createSuggestionSection()
//            case .articles: return self.createArticlesSection()
//            }
//        }
//    }
//    
//    // MARK: - Section Layouts
//    
//    // Title Section (Home + Profile)
//    private func createTitleSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(60)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(60)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 20)
//        
//        return section
//    }
//    
//    // Quote Section
//    private func createQuoteSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(80)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(80)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
//        
//        return section
//    }
//    
//    // Mood Section
//    private func createMoodSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(200)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(200)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
//        
//        return section
//    }
//    
//    // Suggestion Section with Header
//    private func createSuggestionSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(120)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(0.85),
//            heightDimension: .estimated(120)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .groupPaging
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
//        section.interGroupSpacing = 12
//        
//        // Add header
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(44)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // Articles Section with Header
//    private func createArticlesSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(280)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(280)
//        )
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
//        section.interGroupSpacing = 16
//        
//        // Add header
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(44)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // MARK: - Configure Data Source
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(
//            collectionView: HomeCollectionView
//        ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
//            
//            guard let self = self else { return nil }
//            
//            switch item.type {
//            case .title:
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeTitleCell",
//                    for: indexPath
//                ) as? HomeTitleCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureTitleCell(cell)
//                return cell
//                
//            case .quote(let quote):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeQuoteCell",
//                    for: indexPath
//                ) as? HomeQuoteCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureQuoteCell(cell, with: quote)
//                return cell
//                
//            case .mood:
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeMoodCell",
//                    for: indexPath
//                ) as? HomeMoodCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureMoodCell(cell)
//                return cell
//                
//            case .suggestion(let suggestion):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeSuggestionCell",
//                    for: indexPath
//                ) as? HomeSuggestionCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureSuggestionCell(cell, with: suggestion)
//                return cell
//                
//            case .article(let article):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeArticleCell",
//                    for: indexPath
//                ) as? HomeArticleCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureArticleCell(cell, with: article)
//                return cell
//            }
//        }
//        
//        // Configure supplementary views (headers)
//        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
//            
//            guard let self = self else { return nil }
//            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
//            
//            guard let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: "HomeHeaderCell",
//                for: indexPath
//            ) as? HomeHeaderCell else {
//                return UICollectionReusableView()
//            }
//            
//            guard let sectionType = HomeSectionType(rawValue: indexPath.section) else { return header }
//            
//            switch sectionType {
//            case .suggestion:
//                header.configure(title: "Suggested For You")
//            case .articles:
//                header.configure(title: "Articles")
//            default:
//                break
//            }
//            
//            return header
//        }
//    }
//    
//    // MARK: - Cell Configuration
//    
//    private func configureTitleCell(_ cell: HomeTitleCell) {
//        // Try to load profile image, pass nil if not found
//        let profileImage = UIImage(named: "profile_image")
//        cell.configure(title: "Home", profileImage: profileImage)
//    }
//    
//    private func configureQuoteCell(_ cell: HomeQuoteCell, with quote: String) {
//        cell.configure(quote: quote)
//    }
//    
//    private func configureMoodCell(_ cell: HomeMoodCell) {
//        cell.configure(title: "How are you feeling right now?", moods: HomeModel.moods)
//    }
//    
//    private func configureSuggestionCell(_ cell: HomeSuggestionCell, with suggestion: Suggestion) {
//        cell.configure(with: suggestion)
//    }
//    
//    private func configureArticleCell(_ cell: HomeArticleCell, with article: Article) {
//        cell.configure(with: article)
//    }
//    
//    // MARK: - Apply Snapshot
//    private func applySnapshot() {
//        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
//        
//        // Add sections
//        snapshot.appendSections(HomeSectionType.allCases)
//        
//        // Add items to each section
//        snapshot.appendItems([HomeItem(type: .title)], toSection: .title)
//        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
//        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)
//        
//        let suggestionItems = HomeModel.suggestions.map { HomeItem(type: .suggestion($0)) }
//        snapshot.appendItems(suggestionItems, toSection: .suggestion)
//        
//        let articleItems = HomeModel.articles.map { HomeItem(type: .article($0)) }
//        snapshot.appendItems(articleItems, toSection: .articles)
//        
//        dataSource.apply(snapshot, animatingDifferences: false)
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension HomeViewController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//        
//        switch item.type {
//        case .suggestion(let suggestion):
//            print("Selected suggestion: \(suggestion.title)")
//            // Handle suggestion tap
//            // Navigate to detail screen or perform action
//            
//        case .article(let article):
//            print("Selected article: \(article.title)")
//            // Handle article tap
//            // Navigate to article detail screen
//            
//        default:
//            break
//        }
//    }
//}
//
//  HomeViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//
//
//import UIKit
//
//class HomeViewController: UIViewController {
//
//    @IBOutlet weak var HomeCollectionView: UICollectionView!
//    
//    // MARK: - Properties
//    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        registerCells()
//        setupCollectionView()
//        configureDataSource()
//        applySnapshot()
//    }
//    
//    // MARK: - Register Cells
//    private func registerCells() {
//        // Try to register cells from XIB files
//        // If XIBs don't exist, cells should already be registered in Storyboard
//        let cellIdentifiers = [
//            "HomeTitleCell",
//            "HomeQuoteCell",
//            "HomeMoodCell",
//            "HomeSuggestionCell",
//            "HomeArticleCell"
//        ]
//        
//        for identifier in cellIdentifiers {
//            // Try to load XIB, if it fails, assume it's registered in Storyboard
//            if let _ = Bundle.main.path(forResource: identifier, ofType: "nib") {
//                let nib = UINib(nibName: identifier, bundle: nil)
//                HomeCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
//            }
//        }
//        
//        // Try to register header from XIB
//        if let _ = Bundle.main.path(forResource: "HomeHeaderCell", ofType: "nib") {
//            let headerNib = UINib(nibName: "HomeHeaderCell", bundle: nil)
//            HomeCollectionView.register(
//                headerNib,
//                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                withReuseIdentifier: "HomeHeaderCell"
//            )
//        }
//    }
//    
//    // MARK: - Setup Collection View
//    private func setupCollectionView() {
//        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
//        HomeCollectionView.delegate = self
//        HomeCollectionView.backgroundColor = .systemBackground
//        
//        // Use automatic content inset adjustment for safe area
//        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
//        
//        // Ensure no extra padding
//        HomeCollectionView.contentInset = .zero
//    }
//    
//    // MARK: - Create Compositional Layout
//    private func createCompositionalLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
//            guard let sectionType = HomeSectionType(rawValue: sectionIndex) else { return nil }
//            
//            switch sectionType {
//            case .title: return self.createTitleSection()
//            case .quote: return self.createQuoteSection()
//            case .mood: return self.createMoodSection()
//            case .suggestion: return self.createSuggestionSection()
//            case .articles: return self.createArticlesSection()
//            }
//        }
//    }
//    
//    // MARK: - Section Layouts
//    
//    // Title Section (Home + Profile) - FIXED: Now visible with proper height
//    private func createTitleSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(44)  // Fixed height instead of estimated
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(44)  // Fixed height
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
//        
//        return section
//    }
//    
//    // Quote Section
//    private func createQuoteSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(80)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(80)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
//        
//        return section
//    }
//    
//    // Mood Section
//    private func createMoodSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(240)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(240)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 32, trailing: 20)
//        
//        return section
//    }
//    
//    // FIXED: Suggestion Section - Now scrolls HORIZONTALLY
//    private func createSuggestionSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(140)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        // Key fix: group width should be less than 1.0 for horizontal scrolling
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(0.85),  // 85% of container width
//            heightDimension: .estimated(140)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        
//        // CRITICAL: This makes it scroll horizontally!
//        section.orthogonalScrollingBehavior = .groupPaging
//        
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 32, trailing: 20)
//        section.interGroupSpacing = 12  // Space between cards
//        
//        // Add header
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(32)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // Articles Section with Header
//    private func createArticlesSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(280)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(280)
//        )
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20)
//        section.interGroupSpacing = 16
//        
//        // Add header
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(32)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // MARK: - Configure Data Source
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(
//            collectionView: HomeCollectionView
//        ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
//            
//            guard let self = self else { return nil }
//            
//            switch item.type {
//            case .title:
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeTitleCell",
//                    for: indexPath
//                ) as? HomeTitleCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureTitleCell(cell)
//                return cell
//                
//            case .quote(let quote):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeQuoteCell",
//                    for: indexPath
//                ) as? HomeQuoteCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureQuoteCell(cell, with: quote)
//                return cell
//                
//            case .mood:
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeMoodCell",
//                    for: indexPath
//                ) as? HomeMoodCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureMoodCell(cell)
//                return cell
//                
//            case .suggestion(let suggestion):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeSuggestionCell",
//                    for: indexPath
//                ) as? HomeSuggestionCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureSuggestionCell(cell, with: suggestion)
//                return cell
//                
//            case .article(let article):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeArticleCell",
//                    for: indexPath
//                ) as? HomeArticleCell else {
//                    return UICollectionViewCell()
//                }
//                self.configureArticleCell(cell, with: article)
//                return cell
//            }
//        }
//        
//        // Configure supplementary views (headers)
//        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
//            
//            guard let self = self else { return nil }
//            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
//            
//            guard let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: "HomeHeaderCell",
//                for: indexPath
//            ) as? HomeHeaderCell else {
//                return UICollectionReusableView()
//            }
//            
//            guard let sectionType = HomeSectionType(rawValue: indexPath.section) else { return header }
//            
//            switch sectionType {
//            case .suggestion:
//                header.configure(title: "Suggested For You")
//            case .articles:
//                header.configure(title: "Articles")
//            default:
//                break
//            }
//            
//            return header
//        }
//    }
//    
//    // MARK: - Cell Configuration
//    
//    private func configureTitleCell(_ cell: HomeTitleCell) {
//        // Try to load profile image, pass nil if not found
//        let profileImage = UIImage(named: "profile_image")
//        cell.configure(title: "Home", profileImage: profileImage)
//    }
//    
//    private func configureQuoteCell(_ cell: HomeQuoteCell, with quote: String) {
//        cell.configure(quote: quote)
//    }
//    
//    private func configureMoodCell(_ cell: HomeMoodCell) {
//        cell.configure(title: "How are you feeling right now?", moods: HomeModel.moods)
//    }
//    
//    private func configureSuggestionCell(_ cell: HomeSuggestionCell, with suggestion: Suggestion) {
//        cell.configure(with: suggestion)
//    }
//    
//    private func configureArticleCell(_ cell: HomeArticleCell, with article: Article) {
//        cell.configure(with: article)
//    }
//    
//    // MARK: - Apply Snapshot
//    private func applySnapshot() {
//        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
//        
//        // Add sections
//        snapshot.appendSections(HomeSectionType.allCases)
//        
//        // Add items to each section
//        snapshot.appendItems([HomeItem(type: .title)], toSection: .title)
//        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
//        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)
//        
//        let suggestionItems = HomeModel.suggestions.map { HomeItem(type: .suggestion($0)) }
//        snapshot.appendItems(suggestionItems, toSection: .suggestion)
//        
//        let articleItems = HomeModel.articles.map { HomeItem(type: .article($0)) }
//        snapshot.appendItems(articleItems, toSection: .articles)
//        
//        dataSource.apply(snapshot, animatingDifferences: false)
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension HomeViewController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//        
//        switch item.type {
//        case .suggestion(let suggestion):
//            print("Selected suggestion: \(suggestion.title)")
//            // Handle suggestion tap
//            // Navigate to detail screen or perform action
//            
//        case .article(let article):
//            print("Selected article: \(article.title)")
//            // Handle article tap
//            // Navigate to article detail screen
//            
//        default:
//            break
//        }
//    }
//}

//
//  HomeViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//

//import UIKit
//
//class HomeViewController: UIViewController {
//
//    @IBOutlet weak var HomeCollectionView: UICollectionView!
//    
//    // MARK: - Properties
//    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        print("🔍 DEBUG: viewDidLoad started")
//        
//        registerCells()
//        setupCollectionView()
//        configureDataSource()
//        applySnapshot()
//        
//        print("✅ DEBUG: viewDidLoad completed")
//    }
//    
//    // MARK: - Register Cells
//    private func registerCells() {
//        print("🔍 Registering cells...")
//        
//        let cellIdentifiers = [
//            "HomeTitleCell",
//            "HomeQuoteCell",
//            "HomeMoodCell",
//            "HomeSuggestionCell",
//            "HomeArticleCell"
//        ]
//        
//        for identifier in cellIdentifiers {
//            let nib = UINib(nibName: identifier, bundle: nil)
//            HomeCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
//            print("✅ Registered: \(identifier)")
//        }
//        
//        let headerNib = UINib(nibName: "HomeHeaderCell", bundle: nil)
//        HomeCollectionView.register(
//            headerNib,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "HomeHeaderCell"
//        )
//        print("✅ Registered: HomeHeaderCell")
//    }
//    
//    // MARK: - Setup Collection View
//    private func setupCollectionView() {
//        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
//        HomeCollectionView.delegate = self
//        HomeCollectionView.backgroundColor = UIColor(named: "logsbgcolor") ?? .systemBackground
//        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
//    }
//    
//    // MARK: - Create Compositional Layout
//    private func createCompositionalLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
//            guard let sectionType = HomeSectionType(rawValue: sectionIndex) else { return nil }
//            
//            switch sectionType {
//            case .title: return self.createTitleSection()
//            case .quote: return self.createQuoteSection()
//            case .mood: return self.createMoodSection()
//            case .suggestion: return self.createSuggestionSection()
//            case .articles: return self.createArticlesSection()
//            }
//        }
//    }
//    
//    // MARK: - Section Layouts
//    
//    // FIXED: Title Section - Absolute height, no extra top padding
//    private func createTitleSection() -> NSCollectionLayoutSection {
//        print("📐 Title section: FIXED to 44pt height")
//        
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(56)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(56)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        // Minimal padding - let XIB handle internal spacing
//        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
//        
//        return section
//    }
//    
//    // Quote Section
//    private func createQuoteSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(100)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(100)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16)
//        
//        return section
//    }
//    
//    // Mood Section
//    private func createMoodSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(155)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(155)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
//        
//        return section
//    }
//    
//    // FIXED: Suggestion Section - VERTICAL scrolling (no horizontal)
//    private func createSuggestionSection() -> NSCollectionLayoutSection {
//        print("📐 Suggestion section: VERTICAL (no horizontal scrolling)")
//        
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(116)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        // CRITICAL: Width 1.0 = vertical scrolling only
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),  // Full width = no horizontal scroll
//            heightDimension: .estimated(116)
//        )
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        
//        // NO orthogonalScrollingBehavior - we want vertical!
//        
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)
//        section.interGroupSpacing = 12
//        
//        // Add header
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(52)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // Articles Section
//    private func createArticlesSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(273)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(273)
//        )
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 80, trailing: 16)
//        section.interGroupSpacing = 12
//        
//        // Add header
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(52)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // MARK: - Configure Data Source
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(
//            collectionView: HomeCollectionView
//        ) { (collectionView, indexPath, item) -> UICollectionViewCell? in
//            
//            print("🔍 Creating cell for section \(indexPath.section), item \(indexPath.item)")
//            
//            switch item.type {
//            case .title:
//                print("📱 Creating HomeTitleCell")
//                let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeTitleCell",
//                    for: indexPath
//                ) as! HomeTitleCell
//                
//                let profileImage = UIImage(named: "ProfilePhoto")
//                cell.configure(title: "Home", profileImage: profileImage)
//                print("✅ HomeTitleCell created with frame: \(cell.frame)")
//                return cell
//                
//            case .quote(let quote):
//                let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeQuoteCell",
//                    for: indexPath
//                ) as! HomeQuoteCell
//                cell.configure(quote: quote)
//                return cell
//                
//            case .mood:
//                let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeMoodCell",
//                    for: indexPath
//                ) as! HomeMoodCell
//                cell.configure(title: "How are you feeling right now?", moods: HomeModel.moods)
//                return cell
//                
//            case .suggestion(let suggestion):
//                let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeSuggestionCell",
//                    for: indexPath
//                ) as! HomeSuggestionCell
//                cell.configure(with: suggestion)
//                return cell
//                
//            case .article(let article):
//                let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "HomeArticleCell",
//                    for: indexPath
//                ) as! HomeArticleCell
//                cell.configure(with: article)
//                return cell
//            }
//        }
//        
//        // Configure headers
//        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
//            
//            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
//            
//            let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: "HomeHeaderCell",
//                for: indexPath
//            ) as! HomeHeaderCell
//            
//            guard let sectionType = HomeSectionType(rawValue: indexPath.section) else { return header }
//            
//            switch sectionType {
//            case .suggestion:
//                header.configure(title: "Suggested For You")
//            case .articles:
//                header.configure(title: "Articles")
//            default:
//                break
//            }
//            
//            return header
//        }
//    }
//    
//    // MARK: - Apply Snapshot
//    private func applySnapshot() {
//        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
//        
//        snapshot.appendSections(HomeSectionType.allCases)
//        
//        snapshot.appendItems([HomeItem(type: .title)], toSection: .title)
//        print("📊 Added title section: 1 item")
//        
//        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
//        
//        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)
//        
//        let suggestionItems = HomeModel.suggestions.map { HomeItem(type: .suggestion($0)) }
//        snapshot.appendItems(suggestionItems, toSection: .suggestion)
//        print("📊 Added suggestion section: \(suggestionItems.count) item(s)")
//        
//        let articleItems = HomeModel.articles.map { HomeItem(type: .article($0)) }
//        snapshot.appendItems(articleItems, toSection: .articles)
//        
//        dataSource.apply(snapshot, animatingDifferences: false)
//        
//        print("✅ Snapshot applied!")
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension HomeViewController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//        
//        switch item.type {
//        case .suggestion(let suggestion):
//            print("👆 Selected suggestion: \(suggestion.title)")
//            
//        case .article(let article):
//            print("👆 Selected article: \(article.title)")
//            
//        default:
//            break
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("👀 Displaying cell at [\(indexPath.section), \(indexPath.item)] with frame: \(cell.frame)")
//    }
//}

//
//  HomeViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 02/02/26.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var HomeCollectionView: UICollectionView!
    @IBOutlet weak var ProfileButton: UIBarButtonItem!
    
    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupNavigationBar()
        registerCells()
        setupCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
//    // MARK: - Navigation Bar
//    private func setupNavigationBar() {
//        // Large title "Home"
//        navigationItem.title = "Home"
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .always
//        
//        // Profile button on the right
//        let profileImage = UIImage(named: "person.circle.fill") ?? UIImage(systemName: "person.circle.fill")
//        let profileButton = UIBarButtonItem(
//            image: profileImage,
//            style: .plain,
//            target: self,
//            action: #selector(profileButtonTapped)
//        )
//        // Make it circular and sized nicely
////        profileButton.tintColor = .systemGray
//        navigationItem.rightBarButtonItem = profileButton
//    }
    
//    @objc private func profileButtonTapped() {
//        print("👆 Profile button tapped")
//        // TODO: navigate to profile screen
//    }
//
    
    @IBAction func ProfileButtonTapped(_ sender: Any) {
        print("👆 Profile button tapped")
        
    }
    // MARK: - Register Cells
    private func registerCells() {
        // HomeTitleCell removed — title is now in the navigation bar
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
                // Return an empty zero-height section so rawValue indices stay aligned.
                // No items will be added to it in the snapshot.
                return self.createEmptySection()
            case .quote:        return self.createQuoteSection()
            case .mood:         return self.createMoodSection()
            case .suggestion:   return self.createSuggestionSection()
            case .articles:     return self.createArticlesSection()
            }
        }
    }
    
    // MARK: - Section Layouts
    
    // Empty placeholder so the .title rawValue (0) doesn't break the enum mapping
    private func createEmptySection() -> NSCollectionLayoutSection {
        let itemSize   = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let item       = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let group      = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section    = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }
    
    // Quote Section
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
    
    // Mood Section
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
    
    // Suggestion Section
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
        
        // Header
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
    
    // Articles Section
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 80, trailing: 16)
        section.interGroupSpacing = 12
        
        // Header
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
                // Should never be dequeued — no items added to .title section
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
        
        // Configure headers
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HomeHeaderCell",
                for: indexPath
            ) as! HomeHeaderCell
            
            guard let sectionType = HomeSectionType(rawValue: indexPath.section) else { return header }
            
            switch sectionType {
            case .suggestion:
                header.configure(title: "Suggested For You")
            case .articles:
                header.configure(title: "Articles")
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
        
        // .title section intentionally left empty — handled by the nav bar now
        
        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)
        
        let suggestionItems = HomeModel.suggestions.map { HomeItem(type: .suggestion($0)) }
        snapshot.appendItems(suggestionItems, toSection: .suggestion)
        
        let articleItems = HomeModel.articles.map { HomeItem(type: .article($0)) }
        snapshot.appendItems(articleItems, toSection: .articles)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item.type {
        case .suggestion(let suggestion):
            print("👆 Selected suggestion: \(suggestion.title)")
            
        case .article(let article):
            print("👆 Selected article: \(article.title)")
            
        default:
            break
        }
    }
}
