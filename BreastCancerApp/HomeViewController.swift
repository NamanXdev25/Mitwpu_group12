//
//  HomeViewController.swift
//  BreastCancerApp
//
//  Created by Naman Bhansali on 15/12/25.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Cell Identifiers
    let headerId = "HomeHeaderCell"
    let gardenId = "HomeHealingGardenCell"
    let goalId = "HomeTodaysGoalCell"
    let upcomingId = "HomeUpcomingCell"
    let memoryId = "HomeMemoryCell"
    let articleId = "HomeArticleCell"
    let sectionHeaderId = "HomeSectionHeaderView"

    // MARK: - Models (Data Source)
    var goals: [HomeTodaysGoalModel] = []
    var upcomingEvents: [HomeUpcomingModel] = []
    var memories: [HomeMemoryModel] = []
    var articles: [HomeArticleModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Load Data (Calling the local function)
        loadData()
        
        // 2. Setup Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = createCompositionalLayout()
        registerCells()
    }
    
    // MARK: - Data Loading Logic
    func loadData() {
        // IMPORTANT: The strings here must match your file names in Xcode EXACTLY (Case Sensitive)
        // If you named your file "Goals.json", you must write "Goals.json" here.
        goals = loadJSON("Goals.json")
        upcomingEvents = loadJSON("Upcoming.json")
        memories = loadJSON("Memories.json")
        articles = loadJSON("Articles.json")
        
        collectionView.reloadData()
    }
    
    // --- JSON LOADER CODE IS HERE ---
    private func loadJSON<T: Decodable>(_ filename: String) -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            // This error means the file isn't in your project or isn't added to the Target
            fatalError("Failed to locate \(filename) in bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // This error means your JSON syntax is wrong or doesn't match the Model struct
            fatalError("Failed to decode \(filename) from bundle: \(error)")
        }
    }
    
    func registerCells() {
        let cells = [headerId, gardenId, goalId, upcomingId, memoryId, articleId]
        cells.forEach { id in
            collectionView.register(UINib(nibName: id, bundle: nil), forCellWithReuseIdentifier: id)
        }
        collectionView.register(UINib(nibName: sectionHeaderId, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: sectionHeaderId)
    }

    // MARK: - Compositional Layout
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createHomeHeaderSection()
            case 1: return self.createGardenSection()
            case 2: return self.createGoalsSection()
            case 3: return self.createUpcomingSection()
            case 4: return self.createMemoriesSection()
            case 5: return self.createArticlesSection()
            default: return nil
            }
        }
    }

    // --- Layout Definitions ---
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

    func createGoalsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        addHeader(to: section)
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(280))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0)
        addHeader(to: section)
        return section
    }
    
    func addHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
    }

    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 1
        case 2: return goals.count
        case 3: return upcomingEvents.count
        case 4: return memories.count
        case 5: return articles.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerId, for: indexPath) as! HomeHeaderCell
            cell.configure(name: "Sophie")
            return cell
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: gardenId, for: indexPath) as! HomeHealingGardenCell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: goalId, for: indexPath) as! HomeTodaysGoalCell
            let data = goals[indexPath.row]
            cell.configure(title: data.title, points: data.points, imageName: data.iconName, isCompleted: data.isCompleted)
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: upcomingId, for: indexPath) as! HomeUpcomingCell
            let data = upcomingEvents[indexPath.row]
            cell.configure(with: data)
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: memoryId, for: indexPath) as! HomeMemoryCell
            let data = memories[indexPath.row]
            cell.configure(with: data)
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: articleId, for: indexPath) as! HomeArticleCell
            let data = articles[indexPath.row]
            cell.configure(with: data)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionHeaderId, for: indexPath) as! HomeSectionHeaderView
        header.seeAllButton.isHidden = false
        header.seeAllButton.setTitle("See All", for: .normal)
        
        switch indexPath.section {
        case 2:
            header.titleLabel.text = "Today's Goals"
            header.seeAllButton.isHidden = true
        case 3:
            header.titleLabel.text = "Upcoming"
            header.seeAllButton.isHidden = true
        case 4:
            header.titleLabel.text = "Your Memories"
        case 5:
            header.titleLabel.text = "Articles"
        default: break
        }
        return header
    }
}
