//import UIKit
//
//class HomeViewController: UIViewController,
//                          UICollectionViewDelegate,
//                          UIImagePickerControllerDelegate,
//                          UINavigationControllerDelegate,
//                          AddMemoryDelegate {
//
//    @IBOutlet weak var HomeCollectionView: UICollectionView!
//    @IBOutlet weak var ProfileButton: UIBarButtonItem!
//
//    // MARK: - Properties
//    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
//    private var selectedMoodKey: String = "happy"
//    private var hasUserSelectedMood: Bool = false
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        registerCells()
//        setupCollectionView()
//        configureDataSource()
//        applySnapshot()
//    }
//
//    @IBAction func ProfileButtonTapped(_ sender: Any) {
//        print("👆 Profile button tapped")
//    }
//
//    // MARK: - Register Cells
//    private func registerCells() {
//        let cellIdentifiers = [
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
//        HomeCollectionView.backgroundColor = UIColor(named: "logsbgcolor") ?? .systemBackground
//        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
//    }
//
//    // MARK: - Layout
//    private func createCompositionalLayout() -> UICollectionViewLayout {
//        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
//            guard
//                let self = self,
//                let sectionType = HomeSectionType(rawValue: sectionIndex)
//            else { return nil }
//
//            switch sectionType {
//            case .title: return self.createEmptySection()
//            case .quote: return self.createQuoteSection()
//            case .mood: return self.createMoodSection()
//            case .suggestion: return self.createSuggestionSection()
//            case .articles: return self.createArticlesSection()
//            }
//        }
//    }
//
//    private func createEmptySection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = .zero
//        return section
//    }
//
//    private func createQuoteSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16)
//        return section
//    }
//
//    private func createMoodSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(155))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(155))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
//        return section
//    }
//
//    private func createSuggestionSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(116))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(116))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)
//        section.interGroupSpacing = 12
//
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(52))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        return section
//    }
//
//    private func createArticlesSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(273))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(273))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16)
//        section.interGroupSpacing = 12
//
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(52))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        return section
//    }
//
//    // MARK: - Data Source
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(
//            collectionView: HomeCollectionView
//        ) { [weak self] collectionView, indexPath, item in
//            guard let self = self else { return nil }
//
//            switch item.type {
//            case .title:
//                return UICollectionViewCell()
//
//            case .quote(let quote):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeQuoteCell", for: indexPath) as! HomeQuoteCell
//                cell.configure(quote: quote)
//                return cell
//
//            case .mood:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMoodCell", for: indexPath) as! HomeMoodCell
//                cell.configure(
//                    title: "How are you feeling right now?",
//                    moods: HomeModel.moods,
//                    selectedMoodKey: selectedMoodKey,
//                    hasUserSelectedMood: hasUserSelectedMood
//                )
//
//                cell.onMoodTapped = { [weak self] mood in
//                    self?.updateSuggestions(for: mood)
//                }
//                return cell
//
//            case .suggestion(let suggestion):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSuggestionCell", for: indexPath) as! HomeSuggestionCell
//                cell.configure(with: suggestion)
//                return cell
//
//            case .article(let article):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeArticleCell", for: indexPath) as! HomeArticleCell
//                cell.configure(with: article)
//                return cell
//            }
//        }
//
//        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
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
//                header.configure(title: "Suggested For You", showSeeAll: false)
//            case .articles:
//                header.configure(title: "Articles", showSeeAll: true)
//                header.onSeeAllTapped = { [weak self] in
//                    self?.navigateToArticles()
//                }
//            default:
//                break
//            }
//            return header
//        }
//    }
//
//    private func applySnapshot() {
//        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
//        snapshot.appendSections(HomeSectionType.allCases)
//
//        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
//        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)
//
//        let suggestions: [Suggestion] = hasUserSelectedMood
//            ? HomeModel.suggestions(for: selectedMoodKey)
//            : HomeModel.initialSuggestion(for: selectedMoodKey)
//
//        snapshot.appendItems(suggestions.map { HomeItem(type: .suggestion($0)) }, toSection: .suggestion)
//        snapshot.appendItems(HomeModel.articles.map { HomeItem(type: .article($0)) }, toSection: .articles)
//
//        dataSource.apply(snapshot, animatingDifferences: false)
//    }
//
//    private func updateSuggestions(for mood: Mood) {
//        selectedMoodKey = mood.title.lowercased()
//        hasUserSelectedMood = true
//        applySnapshot()
//    }
//
//    // MARK: - Suggestion Actions
//    private func openBreathingSessionAsSheet(withTitle title: String) {
//        let sessions = BreathingDataManager().getAllSessions()
//        guard let session = sessions.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame }) else { return }
//
//        let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
//        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "BreathingPlayerVC") as? BreathingPlayerViewController else { return }
//
//        playerVC.session = session
//        playerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .close,
//            target: self,
//            action: #selector(closePresentedModal)
//        )
//
//        let navController = UINavigationController(rootViewController: playerVC)
//        if let sheet = navController.sheetPresentationController {
//            sheet.detents = [.large()]
//            sheet.prefersGrabberVisible = true
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//        }
//        present(navController, animated: true)
//    }
//
//    private func openBlankJournalAsSheet() {
//        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
//        guard let journalVC = storyboard.instantiateViewController(withIdentifier: "BlankJournalViewController") as? BlankJournalViewController else { return }
//
//        journalVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .close,
//            target: self,
//            action: #selector(closePresentedModal)
//        )
//
//        let navController = UINavigationController(rootViewController: journalVC)
//        if let sheet = navController.sheetPresentationController {
//            sheet.detents = [.large()]
//            sheet.prefersGrabberVisible = true
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//        }
//        present(navController, animated: true)
//    }
//
//    private func openHobbyMemoryOptions(from sourceView: UIView) {
//        let storyboard = UIStoryboard(name: "memory", bundle: nil)
//        let popup = storyboard.instantiateViewController(withIdentifier: "AddMemoryPopupViewController") as! AddMemoryPopupViewController
//
//        popup.modalPresentationStyle = .popover
//        popup.preferredContentSize = CGSize(width: 260, height: 150)
//
//        popup.onCamera = { [weak self] in
//            self?.presentImagePicker(sourceType: .camera)
//        }
//
//        popup.onPhotos = { [weak self] in
//            self?.presentImagePicker(sourceType: .photoLibrary)
//        }
//
//        guard let popover = popup.popoverPresentationController else {
//            present(popup, animated: true)
//            return
//        }
//
//        popover.sourceView = sourceView
//        popover.sourceRect = sourceView.bounds
//        popover.permittedArrowDirections = [.up, .down]
//        popover.delegate = popup
//
//        present(popup, animated: true)
//    }
//
//    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
//        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
//        let picker = UIImagePickerController()
//        picker.sourceType = sourceType
//        picker.delegate = self
//        present(picker, animated: true)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[.originalImage] as? UIImage else {
//            picker.dismiss(animated: true)
//            return
//        }
//
//        picker.dismiss(animated: true) { [weak self] in
//            self?.openAddMemoryScreen(with: image)
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true)
//    }
//
//    private func openAddMemoryScreen(with image: UIImage) {
//        let storyboard = UIStoryboard(name: "memory", bundle: nil)
//        let addVC = storyboard.instantiateViewController(withIdentifier: "AddMemoryViewController") as! AddMemoryViewController
//        addVC.image = image
//        addVC.delegate = self
//        present(UINavigationController(rootViewController: addVC), animated: true)
//    }
//
//    func didAddMemory(_ memory: Memory) {
//        var memories = MemoryStore.load()
//        memories.append(memory)
//        MemoryStore.save(memories)
//    }
//
//    @objc
//    private func closePresentedModal() {
//        presentedViewController?.dismiss(animated: true)
//    }
//
//    // MARK: - Navigation
//    private func navigateToArticles() {
//        let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
//        if let articlesVC = storyboard.instantiateViewController(withIdentifier: "ArticlesViewController") as? ArticlesViewController {
//            navigationController?.pushViewController(articlesVC, animated: true)
//        }
//    }
//
//    // MARK: - Delegate
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//
//        switch item.type {
//        case .suggestion(let suggestion):
//            if suggestion.imageName == "BreathingSessionsImage" {
//                openBreathingSessionAsSheet(withTitle: suggestion.title)
//            } else if suggestion.imageName == "Journal" {
//                openBlankJournalAsSheet()
//            } else if suggestion.imageName == "Cooking" {
//                let sourceView = collectionView.cellForItem(at: indexPath) ?? collectionView
//                openHobbyMemoryOptions(from: sourceView)
//            }
//
//        case .article(let article):
//            let articlesDataSource = ArticlesDataSource()
//            articlesDataSource.loadArticles()
//
//            guard let fullArticle = articlesDataSource.articles.first(where: { $0.title == article.title }) else { return }
//
//            let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
//            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ArticleDetailViewController") as? ArticleDetailViewController {
//                detailVC.article = fullArticle
//
//                let navController = UINavigationController(rootViewController: detailVC)
//                if let sheet = navController.sheetPresentationController {
//                    sheet.detents = [.large()]
//                    sheet.prefersGrabberVisible = true
//                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//                }
//                present(navController, animated: true)
//            }
//
//        default:
//            break
//        }
//    }
//}

import UIKit

class HomeViewController: UIViewController,
                          UICollectionViewDelegate,
                          UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate,
                          AddMemoryDelegate {

    @IBOutlet weak var HomeCollectionView: UICollectionView!
    @IBOutlet weak var ProfileButton: UIBarButtonItem!

    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
    private var selectedMoodKey: String = "happy"
    private var hasUserSelectedMood: Bool = false

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

    private func registerCells() {
        let cellIdentifiers = [
            "HomeQuoteCell",
            "HomeMoodCell",
            "HomeJournalCell",
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

    private func setupCollectionView() {
        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
        HomeCollectionView.delegate = self
        HomeCollectionView.backgroundColor = UIColor(named: "logsbgcolor") ?? .systemBackground
        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard
                let self = self,
                let sectionType = HomeSectionType(rawValue: sectionIndex)
            else { return nil }

            switch sectionType {
            case .title: return self.createEmptySection()
            case .quote: return self.createQuoteSection()
            case .mood: return self.createMoodSection()
            case .journal: return self.createJournalSection()
            case .suggestion: return self.createSuggestionSection()
            case .articles: return self.createArticlesSection()
            }
        }
    }

    private func createEmptySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }

    private func createQuoteSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16)
        return section
    }

    private func createMoodSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(155))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(155))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }

    private func createJournalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16)
        return section
    }

    private func createSuggestionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(116))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(116))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 12

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(52))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }

    private func createArticlesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(273))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(273))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16)
        section.interGroupSpacing = 12

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(52))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(
            collectionView: HomeCollectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return nil }

            switch item.type {
            case .title:
                return UICollectionViewCell()

            case .quote(let quote):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeQuoteCell", for: indexPath) as! HomeQuoteCell
                cell.configure(quote: quote)
                return cell

            case .mood:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMoodCell", for: indexPath) as! HomeMoodCell
                cell.configure(
                    title: "How are you feeling right now?",
                    moods: HomeModel.moods,
                    selectedMoodKey: selectedMoodKey,
                    hasUserSelectedMood: hasUserSelectedMood
                )

                cell.onMoodTapped = { [weak self] mood in
                    self?.updateSuggestions(for: mood)
                }
                return cell

            case .journal(let journalSuggestion):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeJournalCell", for: indexPath) as! HomeJournalCell
                cell.configure(with: journalSuggestion)
                return cell

            case .suggestion(let suggestion):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSuggestionCell", for: indexPath) as! HomeSuggestionCell
                cell.configure(with: suggestion)
                return cell

            case .article(let article):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeArticleCell", for: indexPath) as! HomeArticleCell
                cell.configure(with: article)
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
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

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
        snapshot.appendSections(HomeSectionType.allCases)

        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)
        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)

        let journalSuggestion: Suggestion = hasUserSelectedMood
            ? HomeModel.journalSuggestion(for: selectedMoodKey)
            : HomeModel.initialJournalSuggestion(for: selectedMoodKey)

        snapshot.appendItems([HomeItem(type: .journal(journalSuggestion))], toSection: .journal)

        let suggestions: [Suggestion] = hasUserSelectedMood
            ? HomeModel.suggestions(for: selectedMoodKey)
            : HomeModel.initialSuggestion(for: selectedMoodKey)

        snapshot.appendItems(suggestions.map { HomeItem(type: .suggestion($0)) }, toSection: .suggestion)
        snapshot.appendItems(HomeModel.articles.map { HomeItem(type: .article($0)) }, toSection: .articles)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateSuggestions(for mood: Mood) {
        selectedMoodKey = mood.title.lowercased()
        hasUserSelectedMood = true
        applySnapshot()
    }

    private func openBreathingSessionAsSheet(withTitle title: String) {
        let sessions = BreathingDataManager().getAllSessions()
        guard let session = sessions.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame }) else { return }

        let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "BreathingPlayerVC") as? BreathingPlayerViewController else { return }

        playerVC.session = session
        playerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePresentedModal)
        )

        let navController = UINavigationController(rootViewController: playerVC)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(navController, animated: true)
    }

    private func openBlankJournalAsSheet(prefilledTitle: String? = nil) {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        guard let journalVC = storyboard.instantiateViewController(withIdentifier: "BlankJournalViewController") as? BlankJournalViewController else { return }

        journalVC.prefilledTitle = prefilledTitle
        journalVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePresentedModal)
        )

        let navController = UINavigationController(rootViewController: journalVC)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(navController, animated: true)
    }


    private func openHobbyMemoryOptions(from sourceView: UIView) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)
        let popup = storyboard.instantiateViewController(withIdentifier: "AddMemoryPopupViewController") as! AddMemoryPopupViewController

        popup.modalPresentationStyle = .popover
        popup.preferredContentSize = CGSize(width: 260, height: 150)

        popup.onCamera = { [weak self] in
            self?.presentImagePicker(sourceType: .camera)
        }

        popup.onPhotos = { [weak self] in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }

        guard let popover = popup.popoverPresentationController else {
            present(popup, animated: true)
            return
        }

        popover.sourceView = sourceView
        popover.sourceRect = sourceView.bounds
        popover.permittedArrowDirections = [.up, .down]
        popover.delegate = popup

        present(popup, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }

        picker.dismiss(animated: true) { [weak self] in
            self?.openAddMemoryScreen(with: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func openAddMemoryScreen(with image: UIImage) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddMemoryViewController") as! AddMemoryViewController
        addVC.image = image
        addVC.delegate = self
        present(UINavigationController(rootViewController: addVC), animated: true)
    }

    func didAddMemory(_ memory: Memory) {
        // 1. Persist the new memory
        var memories = MemoryStore.load()
        memories.append(memory)
        MemoryStore.save(memories)

        // 2. Award coins once per day — shared key with MemoriesViewController.
        //    Whichever screen the user adds a memory on first (Home hobby card OR
        //    the Memories/mindfulness section) claims the daily reward.
        //    Any further memory creation the same day is silently skipped.
        CoinRewardService.shared.awardMemoryCoinsIfEligible(on: self)
    }

    @objc
    private func closePresentedModal() {
        presentedViewController?.dismiss(animated: true)
    }

    private func navigateToArticles() {
        let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
        if let articlesVC = storyboard.instantiateViewController(withIdentifier: "ArticlesViewController") as? ArticlesViewController {
            navigationController?.pushViewController(articlesVC, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item.type {
        case .journal(let journalSuggestion):
            openBlankJournalAsSheet(prefilledTitle: journalSuggestion.title)

        case .suggestion(let suggestion):
            // Detect breathing by matching title with Breathing sessions list
            let sessions = BreathingDataManager().getAllSessions()
            let isBreathingSuggestion = sessions.contains {
                $0.title.caseInsensitiveCompare(suggestion.title) == .orderedSame
            }

            if isBreathingSuggestion {
                openBreathingSessionAsSheet(withTitle: suggestion.title)   // opens same session modally
            } else if suggestion.imageName == "Cooking" {
                let sourceView = collectionView.cellForItem(at: indexPath) ?? collectionView
                openHobbyMemoryOptions(from: sourceView)
            }


        case .article(let article):
            let articlesDataSource = ArticlesDataSource()
            articlesDataSource.loadArticles()

            guard let fullArticle = articlesDataSource.articles.first(where: { $0.title == article.title }) else { return }

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
