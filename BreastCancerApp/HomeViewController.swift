import UIKit

class HomeViewController: UIViewController,
                          UICollectionViewDelegate,
                          UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate,
                          AddMemoryDelegate {

    @IBOutlet weak var HomeCollectionView: UICollectionView!
    @IBOutlet weak var ProfileButton: UIBarButtonItem!

    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!
    private var selectedMoodKey: String = "happy"
    private var hasUserSelectedMood: Bool = false
    private var currentJournalSuggestion: Suggestion?
    private var currentSuggestions: [Suggestion] = []
    private var recentlyShownJournalTitles = Set<String>()
    private var recentlyShownBreathingTitles = Set<String>()
    private var recentlyShownHobbyTitles = Set<String>()
    private var dailySuggestionCache: [String: DailySuggestionCache] = [:]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        setupCollectionView()
        configureDataSource()
        refreshDefaultSuggestions()
        applySnapshot()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(journeyStateChanged),
            name: JourneyState.didChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func ProfileButtonTapped(_ sender: Any) {
        print("👆 Profile button tapped")
    }

    // MARK: - Journey State Observer
    // Called whenever JourneyState changes (phase added, deleted, type changed, etc.).
    // Only redraws the snapshot so the journey card label updates immediately.
    // Suggestions are intentionally NOT rebuilt here — they are stable for the day
    // and the new treatment context flows into the weighted algorithm on the next session.
    @objc private func journeyStateChanged() {
        applySnapshot()
    }

    // MARK: - Dynamic Mood Header
    private func moodHeaderTitle() -> String {
        HomeModel.moodHeaderText(for: selectedMoodKey, hasUserSelectedMood: hasUserSelectedMood)
    }

    // MARK: - Register Cells
    private func registerCells() {
        let cellIdentifiers = [
            "HomeQuoteCell",
            "HomeJourneyCell",
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

    // MARK: - Setup Collection View
    private func setupCollectionView() {
        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
        HomeCollectionView.delegate = self
        HomeCollectionView.backgroundColor = UIColor(named: "logsbgcolor") ?? .systemBackground
        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
    }

    // MARK: - Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard
                let self = self,
                let sectionType = HomeSectionType(rawValue: sectionIndex)
            else { return nil }

            switch sectionType {
            case .title:      return self.createEmptySection()
            case .quote:      return self.createQuoteSection()
            case .journey:    return self.createJourneySection()
            case .mood:       return self.createMoodSection()
            case .journal:    return self.createJournalSection()
            case .suggestion: return self.createSuggestionSection()
            case .articles:   return self.createArticlesSection()
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

    private func createJourneySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16)
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

    // MARK: - Data Source
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

            case .journey(let treatment, let phase):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeJourneyCell", for: indexPath) as! HomeJourneyCell
                cell.configure(treatment: treatment, phase: phase)
                return cell

            case .mood:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMoodCell", for: indexPath) as! HomeMoodCell
                cell.configure(
                    title: moodHeaderTitle(),
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

        let journeyItem = HomeItem(type: .journey(
            treatment: journeyCellTreatmentText(),
                phase: journeyCellPhaseText()
        ))
        snapshot.appendItems([journeyItem], toSection: .journey)

        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)

        if hasUserSelectedMood, let journalSuggestion = currentJournalSuggestion {
            snapshot.appendItems([HomeItem(type: .journal(journalSuggestion))], toSection: .journal)
        }

        let suggestions = currentSuggestions.isEmpty
            ? HomeModel.randomSuggestions(for: selectedMoodKey)
            : currentSuggestions
        snapshot.appendItems(suggestions.map { HomeItem(type: .suggestion($0)) }, toSection: .suggestion)
        snapshot.appendItems(HomeModel.articles.map { HomeItem(type: .article($0)) }, toSection: .articles)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateSuggestions(for mood: Mood) {
        selectedMoodKey = mood.title.lowercased()
        hasUserSelectedMood = true
        refreshMoodSuggestions(for: selectedMoodKey)
        applySnapshot()
    }

    private func refreshDefaultSuggestions() {
        currentJournalSuggestion = nil
        currentSuggestions = HomeSuggestionEngine.defaultSuggestions(
            avoiding: recentlyShownBreathingTitles,
            avoiding: recentlyShownHobbyTitles
        )
        trackShownSuggestions()
        trimHistoryIfNeeded()
    }

    private func refreshMoodSuggestions(for moodKey: String) {
        let cacheKey = dailyCacheKey(for: moodKey)

        if let cached = dailySuggestionCache[cacheKey] {
            currentJournalSuggestion = Suggestion(
                imageName: "Journal",
                title: cached.journalPrompt,
                subtitle: "Start Writing..."
            )
            currentSuggestions = [
                Suggestion(imageName: cached.breathingImage, title: cached.breathingTitle, subtitle: cached.breathingSubtitle),
                Suggestion(imageName: cached.hobbyImage, title: cached.hobbyTitle, subtitle: cached.hobbySubtitle)
            ]
            return
        }

        currentJournalSuggestion = HomeModel.randomJournalSuggestion(
            for: moodKey,
            avoidingTitles: recentlyShownJournalTitles
        )
        currentSuggestions = HomeSuggestionEngine.moodSuggestions(
            for: moodKey,
            avoiding: recentlyShownBreathingTitles,
            avoiding: recentlyShownHobbyTitles
        )

        if let journal = currentJournalSuggestion,
           currentSuggestions.count >= 2 {
            let b = currentSuggestions[0]
            let h = currentSuggestions[1]
            dailySuggestionCache[cacheKey] = DailySuggestionCache(
                breathingTitle: b.title,
                breathingSubtitle: b.subtitle,
                breathingImage: b.imageName,
                hobbyTitle: h.title,
                hobbySubtitle: h.subtitle,
                hobbyImage: h.imageName,
                journalPrompt: journal.title
            )
        }

        if let t = currentJournalSuggestion?.title.normalizedSuggestionTitle {
            recentlyShownJournalTitles.insert(t)
        }
        trackShownSuggestions()
        trimHistoryIfNeeded()
    }

    private func trackShownSuggestions() {
        if let t = currentSuggestions.first?.title.normalizedSuggestionTitle {
            recentlyShownBreathingTitles.insert(t)
        }
        if currentSuggestions.count > 1 {
            recentlyShownHobbyTitles.insert(currentSuggestions[1].title.normalizedSuggestionTitle)
        }
    }

    private func trimHistoryIfNeeded() {
        if recentlyShownJournalTitles.count > 12 {
            recentlyShownJournalTitles.removeAll()
            if let title = currentJournalSuggestion?.title.normalizedSuggestionTitle {
                recentlyShownJournalTitles.insert(title)
            }
        }

        if recentlyShownBreathingTitles.count > 8 {
            recentlyShownBreathingTitles.removeAll()
            if let title = currentSuggestions.first?.title.normalizedSuggestionTitle {
                recentlyShownBreathingTitles.insert(title)
            }
        }

        if recentlyShownHobbyTitles.count > 8 {
            recentlyShownHobbyTitles.removeAll()
            if currentSuggestions.count > 1 {
                let title = currentSuggestions[1].title.normalizedSuggestionTitle
                recentlyShownHobbyTitles.insert(title)
            }
        }
    }

    // MARK: - Actions
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

        popup.onCamera = { [weak self] in self?.presentImagePicker(sourceType: .camera) }
        popup.onPhotos  = { [weak self] in self?.presentImagePicker(sourceType: .photoLibrary) }

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
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
        var memories = MemoryStore.load()
        memories.append(memory)
        MemoryStore.save(memories)
        CoinRewardService.shared.awardMemoryCoinsIfEligible(on: self)
    }

    @objc
    private func closePresentedModal() {
        presentedViewController?.dismiss(animated: true)
    }

    // MARK: - Navigation
    private func navigateToArticles() {
        let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
        if let articlesVC = storyboard.instantiateViewController(withIdentifier: "ArticlesViewController") as? ArticlesViewController {
            navigationController?.pushViewController(articlesVC, animated: true)
        }
    }

    private func navigateToJourney() {
        let sb = UIStoryboard(name: "JourneyMain", bundle: nil)

        if let journeyVC = sb.instantiateViewController(withIdentifier: "JourneyViewController") as? JourneyViewController {
            navigationController?.pushViewController(journeyVC, animated: true)
            return
        }

        if let journeyDetailsVC = sb.instantiateViewController(withIdentifier: "JourneyDetailsViewController") as? JourneyDetailsViewController {
            navigationController?.pushViewController(journeyDetailsVC, animated: true)
            return
        }

        print("Journey screen not found. Check storyboard name and ViewController identifier.")
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item.type {
        case .journey(_, _):
            navigateToJourney()

        case .journal(let journalSuggestion):
            openBlankJournalAsSheet(prefilledTitle: journalSuggestion.title)

        case .suggestion(let suggestion):
            let sessions = BreathingDataManager().getAllSessions()
            let isBreathingSuggestion = sessions.contains {
                $0.title.caseInsensitiveCompare(suggestion.title) == .orderedSame
            }

            if isBreathingSuggestion {
                UserActivityStore.shared.recordBreathingTap(title: suggestion.title)
                openBreathingSessionAsSheet(withTitle: suggestion.title)
            } else if HomeModel.isHobbySuggestion(title: suggestion.title) {
                UserActivityStore.shared.recordHobbyTap(title: suggestion.title)
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

    private func dailyCacheKey(for moodKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(moodKey)_\(formatter.string(from: Date()))"
    }

    private func journeyCellTreatmentText() -> String {
        let js = JourneyState.shared

        guard js.isDiagnosisCompleted else { return "Diagnosis" }

        if js.currentStepTitle == "Treatment" || js.isTreatmentCompleted {
            let name = js.currentTreatmentName
            if name == "Not started yet" || name.isEmpty { return "Treatment" }
            return name
        }

        if js.currentStepTitle == "Post-Treatment" {
            return "Post-Treatment"
        }

        return "Diagnosed"
    }

    private func journeyCellPhaseText() -> String {
        let js = JourneyState.shared

        guard js.isDiagnosisCompleted else { return "Not Updated" }

        if js.currentStepTitle == "Post-Treatment" && js.isTreatmentCompleted {
            return "Recovery"
        }

        if js.currentStepTitle == "Treatment" || js.isTreatmentCompleted {
            let phases = js.persistedPhaseStates
            let savedPhases = phases.filter { $0.isSaved }

            if js.isTreatmentCompleted {
                return "Completed"
            }

            let inProgress = phases.firstIndex { $0.statusRaw == "inProgress" }
            let phaseNumber = (inProgress ?? savedPhases.count) + 1
            return "Phase \(phaseNumber)"
        }

        return "Waiting"
    }
}

private struct DailySuggestionCache {
    let breathingTitle: String
    let breathingSubtitle: String
    let breathingImage: String
    let hobbyTitle: String
    let hobbySubtitle: String
    let hobbyImage: String
    let journalPrompt: String
}

private extension String {
    var normalizedSuggestionTitle: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

extension HomeModel {
    static func moodHeaderText(for moodKey: String, hasUserSelectedMood: Bool) -> String {
        guard hasUserSelectedMood else {
            return "How are you feeling right now?"
        }

        switch moodKey.lowercased() {
        case "anxious":
            return "Take a breath - you're safe here"
        case "sad":
            return "Let's take this gently today"
        case "tired":
            return "Energy feels low - We've got you"
        case "happy":
            return "Keep the good energy going"
        case "excited":
            return "Great to see you feeling excited!"
        default:
            return "How are you feeling right now?"
        }
    }
}
