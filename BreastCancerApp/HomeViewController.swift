import UIKit

class HomeViewController: UIViewController,
                          UICollectionViewDelegate,
                          UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate,
                          AddMemoryDelegate {

    @IBOutlet weak var HomeCollectionView: UICollectionView!
    @IBOutlet weak var ProfileButton: UIBarButtonItem!

    // MARK: - Mood state
    // selectedMoodKey and hasUserSelectedMood are persisted to UserDefaults keyed by today's
    // date so they survive app close/reopen within the same day and reset automatically the
    // next day.
    private var selectedMoodKey:      String = "happy"
    private var hasUserSelectedMood:  Bool   = false

    // MARK: - Suggestion state
    private var currentJournalSuggestion: Suggestion?
    private var currentSuggestions:       [Suggestion] = []

    // Recently-shown tracking (in-memory; resets on fresh launch which is acceptable —
    // the daily cache prevents exact-same suggestions within a day regardless).
    private var recentlyShownJournalTitles  = Set<String>()
    private var recentlyShownBreathingTitles = Set<String>()
    private var recentlyShownHobbyTitles    = Set<String>()

    // Daily suggestion cache — persisted to UserDefaults so suggestions survive
    // app close/reopen within the same day.
    // Key format: "<moodKey>_<yyyy-MM-dd>"
    private var dailySuggestionCache: [String: DailySuggestionCache] = [:]

    // MARK: - UserDefaults keys
    private let kMoodKey             = "home_selectedMoodKey"
    private let kHasMoodSelected     = "home_hasUserSelectedMood"
    private let kMoodDate            = "home_moodDate"       // date the mood was set
    private let kDailyCacheData      = "home_dailyCacheData" // archived cache dictionary

    // MARK: - DataSource
    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreMoodState()
        restoreDailyCache()
        registerCells()
        setupCollectionView()
        configureDataSource()

        if hasUserSelectedMood {
            // Re-hydrate suggestions from cache (or regenerate if cache missing)
            refreshMoodSuggestions(for: selectedMoodKey)
        } else {
            refreshDefaultSuggestions()
        }

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
    // Called whenever JourneyState changes.
    // Only redraws the snapshot so the journey card label updates immediately.
    // Suggestions are NOT rebuilt here — caching rules decide when they update.
    @objc private func journeyStateChanged() {
        applySnapshot()
    }

    // MARK: - Mood persistence

    /// Restores mood selection from UserDefaults.
    /// If the saved mood date is not today, clears the saved state (next-day reset).
    private func restoreMoodState() {
        let today = todayDateString()
        let savedDate = UserDefaults.standard.string(forKey: kMoodDate) ?? ""

        if savedDate == today {
            selectedMoodKey     = UserDefaults.standard.string(forKey: kMoodKey) ?? "happy"
            hasUserSelectedMood = UserDefaults.standard.bool(forKey: kHasMoodSelected)
        } else {
            // New day — clear persisted mood so home starts fresh
            clearPersistedMood()
        }
    }

    private func persistMoodState() {
        UserDefaults.standard.set(selectedMoodKey,     forKey: kMoodKey)
        UserDefaults.standard.set(hasUserSelectedMood, forKey: kHasMoodSelected)
        UserDefaults.standard.set(todayDateString(),   forKey: kMoodDate)
    }

    private func clearPersistedMood() {
        selectedMoodKey     = "happy"
        hasUserSelectedMood = false
        UserDefaults.standard.removeObject(forKey: kMoodKey)
        UserDefaults.standard.removeObject(forKey: kHasMoodSelected)
        UserDefaults.standard.removeObject(forKey: kMoodDate)
    }

    // MARK: - Daily cache persistence

    private func restoreDailyCache() {
        guard let raw = UserDefaults.standard.data(forKey: kDailyCacheData),
              let decoded = try? JSONDecoder().decode([String: DailySuggestionCache].self, from: raw)
        else { return }

        // Only keep entries for today — silently drop yesterday's cache
        let today = todayDateString()
        dailySuggestionCache = decoded.filter { $0.key.hasSuffix(today) }
    }

    private func persistDailyCache() {
        guard let data = try? JSONEncoder().encode(dailySuggestionCache) else { return }
        UserDefaults.standard.set(data, forKey: kDailyCacheData)
    }

    // MARK: - Helpers

    private func todayDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private func dailyCacheKey(for moodKey: String) -> String {
        "\(moodKey)_\(todayDateString())"
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
            HomeCollectionView.register(
                UINib(nibName: identifier, bundle: nil),
                forCellWithReuseIdentifier: identifier
            )
        }
        HomeCollectionView.register(
            UINib(nibName: "HomeHeaderCell", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HomeHeaderCell"
        )
    }

    // MARK: - Setup Collection View
    private func setupCollectionView() {
        HomeCollectionView.collectionViewLayout = createCompositionalLayout()
        HomeCollectionView.delegate             = self
        HomeCollectionView.backgroundColor      = UIColor(named: "logsbgcolor") ?? .systemBackground
        HomeCollectionView.contentInsetAdjustmentBehavior = .automatic
    }

    // MARK: - Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self,
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
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))
        let section   = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
        section.contentInsets = .zero
        return section
    }

    private func createQuoteSection() -> NSCollectionLayoutSection {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let section   = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16)
        return section
    }

    private func createJourneySection() -> NSCollectionLayoutSection {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
        let section   = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16)
        return section
    }

    private func createMoodSection() -> NSCollectionLayoutSection {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(155))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(155))
        let section   = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(52))
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        return section
    }

    private func createJournalSection() -> NSCollectionLayoutSection {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let section   = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16)
        return section
    }

    private func createSuggestionSection() -> NSCollectionLayoutSection {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(116))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(116))
        let group     = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section   = NSCollectionLayoutSection(group: group)
        section.contentInsets     = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 12

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(52))
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        return section
    }

    private func createArticlesSection() -> NSCollectionLayoutSection {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(273))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(273))
        let group     = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
        let section   = NSCollectionLayoutSection(group: group)
        section.contentInsets     = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16)
        section.interGroupSpacing = 12

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(52))
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        return section
    }

    // MARK: - Data Source
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeItem>(
            collectionView: HomeCollectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self else { return nil }

            switch item.type {
            case .title:
                return UICollectionViewCell()

            case .quote(let quote):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeQuoteCell", for: indexPath
                ) as! HomeQuoteCell
                cell.configure(quote: quote)
                return cell

            case .journey(let stage):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeJourneyCell", for: indexPath
                ) as! HomeJourneyCell
                cell.configure(journeyStage: stage)
                return cell

            case .mood:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeMoodCell", for: indexPath
                ) as! HomeMoodCell
                cell.configure(
                    title:              self.moodHeaderTitle(),
                    moods:              HomeModel.moods,
                    selectedMoodKey:    self.selectedMoodKey,
                    hasUserSelectedMood: self.hasUserSelectedMood
                )
                cell.onMoodTapped = { [weak self] mood in
                    self?.updateSuggestions(for: mood)
                }
                return cell

            case .journal(let journalSuggestion):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeJournalCell", for: indexPath
                ) as! HomeJournalCell
                cell.configure(with: journalSuggestion)
                return cell

            case .suggestion(let suggestion):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeSuggestionCell", for: indexPath
                ) as! HomeSuggestionCell
                cell.configure(with: suggestion)
                return cell

            case .article(let article):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "HomeArticleCell", for: indexPath
                ) as! HomeArticleCell
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
            case .mood:
                header.configure(title: "Daily Check-In", showSeeAll: false)
            case .suggestion:
                header.configure(title: "Suggested For You", showSeeAll: false)
            case .articles:
                header.configure(title: "Articles", showSeeAll: true)
                header.onSeeAllTapped = { [weak self] in self?.navigateToArticles() }
            default:
                break
            }
            return header
        }
    }

    // MARK: - Snapshot

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeItem>()
        snapshot.appendSections(HomeSectionType.allCases)

        snapshot.appendItems([HomeItem(type: .quote(HomeModel.quote))], toSection: .quote)

        snapshot.appendItems([HomeItem(type: .journey(
            stage: journeyStageText()
        ))], toSection: .journey)

        snapshot.appendItems([HomeItem(type: .mood)], toSection: .mood)

        if hasUserSelectedMood, let journalSuggestion = currentJournalSuggestion {
            snapshot.appendItems(
                [HomeItem(type: .journal(journalSuggestion))],
                toSection: .journal
            )
        }

        let suggestions = currentSuggestions.isEmpty
            ? HomeModel.randomSuggestions(for: selectedMoodKey)
            : currentSuggestions
        snapshot.appendItems(
            suggestions.map { HomeItem(type: .suggestion($0)) },
            toSection: .suggestion
        )

        snapshot.appendItems(
            HomeModel.articles.map { HomeItem(type: .article($0)) },
            toSection: .articles
        )

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Suggestion refresh

    private func updateSuggestions(for mood: Mood) {
        selectedMoodKey     = mood.title.lowercased()
        hasUserSelectedMood = true
        persistMoodState()
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

        // Return cached suggestions if available — this is intentional:
        // once a mood's suggestions are generated for the day they stay stable
        // even if journey state changes mid-day. The new journey context flows
        // in on the next mood selection or next day.
        if let cached = dailySuggestionCache[cacheKey] {
            currentJournalSuggestion = Suggestion(
                imageName: "Journal",
                title:     cached.journalPrompt,
                subtitle:  "Start Writing..."
            )
            currentSuggestions = [
                Suggestion(imageName: cached.breathingImage, title: cached.breathingTitle, subtitle: cached.breathingSubtitle),
                Suggestion(imageName: cached.hobbyImage,     title: cached.hobbyTitle,     subtitle: cached.hobbySubtitle)
            ]
            return
        }

        // Generate fresh suggestions using the weighted engine
        currentJournalSuggestion = HomeModel.randomJournalSuggestion(
            for: moodKey,
            avoidingTitles: recentlyShownJournalTitles
        )
        currentSuggestions = HomeSuggestionEngine.moodSuggestions(
            for: moodKey,
            avoiding: recentlyShownBreathingTitles,
            avoiding: recentlyShownHobbyTitles
        )

        // Cache and persist so suggestions survive app close/reopen today
        if let journal = currentJournalSuggestion,
           currentSuggestions.count >= 2 {
            let b = currentSuggestions[0]
            let h = currentSuggestions[1]
            dailySuggestionCache[cacheKey] = DailySuggestionCache(
                breathingTitle:    b.title,
                breathingSubtitle: b.subtitle,
                breathingImage:    b.imageName,
                hobbyTitle:        h.title,
                hobbySubtitle:     h.subtitle,
                hobbyImage:        h.imageName,
                journalPrompt:     journal.title
            )
            persistDailyCache()
        }

        if let t = currentJournalSuggestion?.title.normalizedSuggestionTitle {
            recentlyShownJournalTitles.insert(t)
        }
        trackShownSuggestions()
        trimHistoryIfNeeded()
    }

    // MARK: - Suggestion tracking

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
            if let t = currentJournalSuggestion?.title.normalizedSuggestionTitle {
                recentlyShownJournalTitles.insert(t)
            }
        }
        if recentlyShownBreathingTitles.count > 8 {
            recentlyShownBreathingTitles.removeAll()
            if let t = currentSuggestions.first?.title.normalizedSuggestionTitle {
                recentlyShownBreathingTitles.insert(t)
            }
        }
        if recentlyShownHobbyTitles.count > 8 {
            recentlyShownHobbyTitles.removeAll()
            if currentSuggestions.count > 1 {
                recentlyShownHobbyTitles.insert(currentSuggestions[1].title.normalizedSuggestionTitle)
            }
        }
    }

    // MARK: - Journey cell text helper

    /// Returns the single stage label shown on the Home journey card.
    /// Progression: Not Started Yet → Diagnosed → Waiting for Result
    ///              → <Treatment type e.g. Surgery / Radiation Therapy> → Recovery
    private func journeyStageText() -> String {
        let js = JourneyState.shared

        // Nothing saved in journey yet
        guard js.isDiagnosisCompleted else { return "Not Started Yet" }

        // Post-treatment always shows Recovery
        if js.currentStepTitle == "Post-Treatment" { return "Recovery" }

        // Active treatment — prefer the in-progress phase name, then last saved phase
        if js.currentStepTitle == "Treatment" || js.isTreatmentCompleted {
            let phases = js.persistedPhaseStates
            // 1. In-progress phase takes highest priority
            if let inProgress = phases.first(where: { $0.statusRaw == "inProgress" }),
               !inProgress.treatmentTypeRaw.isEmpty,
               inProgress.treatmentTypeRaw != "none" {
                return inProgress.treatmentTypeRaw
            }
            // 2. Last saved phase as fallback
            if let lastSaved = phases
                .filter({ $0.isSaved && !$0.treatmentTypeRaw.isEmpty && $0.treatmentTypeRaw != "none" })
                .last {
                return lastSaved.treatmentTypeRaw
            }
            // 3. Stored treatment name (legacy / edge-case)
            let name = js.currentTreatmentName
            if name != "Not started yet" && !name.isEmpty { return name }
            return "Treatment"
        }

        if js.currentStepTitle == "Waiting for Result" { return "Waiting for Result" }
        return "Diagnosed"
    }

    // MARK: - Actions

    private func openBreathingSessionAsSheet(withTitle title: String) {
        let sessions = BreathingDataManager().getAllSessions()
        guard let session = sessions.first(where: {
            $0.title.caseInsensitiveCompare(title) == .orderedSame
        }) else { return }

        let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(
            withIdentifier: "BreathingPlayerVC"
        ) as? BreathingPlayerViewController else { return }

        playerVC.session = session
        playerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closePresentedModal)
        )
        let nav = UINavigationController(rootViewController: playerVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(nav, animated: true)
    }

    private func openBlankJournalAsSheet(prefilledTitle: String? = nil) {
        let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
        guard let journalVC = storyboard.instantiateViewController(
            withIdentifier: "BlankJournalViewController"
        ) as? BlankJournalViewController else { return }

        journalVC.prefilledTitle = prefilledTitle
        journalVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closePresentedModal)
        )
        let nav = UINavigationController(rootViewController: journalVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(nav, animated: true)
    }

    private func openHobbyMemoryOptions(from sourceView: UIView) {
        let storyboard = UIStoryboard(name: "memory", bundle: nil)
        let popup = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryPopupViewController"
        ) as! AddMemoryPopupViewController

        popup.modalPresentationStyle = .popover
        popup.preferredContentSize   = CGSize(width: 260, height: 150)
        popup.onCamera = { [weak self] in self?.presentImagePicker(sourceType: .camera) }
        popup.onPhotos = { [weak self] in self?.presentImagePicker(sourceType: .photoLibrary) }

        guard let popover = popup.popoverPresentationController else {
            present(popup, animated: true)
            return
        }
        popover.sourceView              = sourceView
        popover.sourceRect              = sourceView.bounds
        popover.permittedArrowDirections = [.up, .down]
        popover.delegate                = popup
        present(popup, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker        = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate   = self
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
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
        let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddMemoryViewController"
        ) as! AddMemoryViewController
        addVC.image    = image
        addVC.delegate = self
        present(UINavigationController(rootViewController: addVC), animated: true)
    }

    func didAddMemory(_ memory: Memory) {
        var memories = MemoryStore.load()
        memories.append(memory)
        MemoryStore.save(memories)
        CoinRewardService.shared.awardMemoryCoinsIfEligible(on: self)
    }

    @objc private func closePresentedModal() {
        presentedViewController?.dismiss(animated: true)
    }

    // MARK: - Navigation

    private func navigateToArticles() {
        let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "ArticlesViewController"
        ) as? ArticlesViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func navigateToJourney() {
        let sb = UIStoryboard(name: "JourneyMain", bundle: nil)
        if let vc = sb.instantiateViewController(
            withIdentifier: "JourneyViewController"
        ) as? JourneyViewController {
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        if let vc = sb.instantiateViewController(
            withIdentifier: "JourneyDetailsViewController"
        ) as? JourneyDetailsViewController {
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        print("Journey screen not found. Check storyboard name and ViewController identifier.")
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item.type {
        case .journey:
            navigateToJourney()

        case .journal(let journalSuggestion):
            openBlankJournalAsSheet(prefilledTitle: journalSuggestion.title)

        case .suggestion(let suggestion):
            let sessions = BreathingDataManager().getAllSessions()
            let isBreathing = sessions.contains {
                $0.title.caseInsensitiveCompare(suggestion.title) == .orderedSame
            }
            if isBreathing {
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
            guard let fullArticle = articlesDataSource.articles.first(
                where: { $0.title == article.title }
            ) else { return }
            let storyboard = UIStoryboard(name: "ArticlesMain", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(
                withIdentifier: "ArticleDetailViewController"
            ) as? ArticleDetailViewController {
                detailVC.article = fullArticle
                let nav = UINavigationController(rootViewController: detailVC)
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                }
                present(nav, animated: true)
            }

        default:
            break
        }
    }
}

// MARK: - DailySuggestionCache (Codable for UserDefaults persistence)

private struct DailySuggestionCache: Codable {
    let breathingTitle:    String
    let breathingSubtitle: String
    let breathingImage:    String
    let hobbyTitle:        String
    let hobbySubtitle:     String
    let hobbyImage:        String
    let journalPrompt:     String
}

// MARK: - String helper

private extension String {
    var normalizedSuggestionTitle: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
