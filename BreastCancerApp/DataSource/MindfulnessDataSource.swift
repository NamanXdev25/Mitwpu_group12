import UIKit

class MindfulnessDataSource: NSObject, UICollectionViewDataSource {
    weak var viewController: MindfulnessViewController?
    private(set) var memories: [Memory] = []

    private var recentMemories: [Memory] {
        Array(memories.prefix(3))
    }

    init(viewController: MindfulnessViewController) {
        self.viewController = viewController
        super.init()
        reloadMemories()
    }

    func reloadMemories() {
        memories = MemoryStore.load().sorted { $0.date > $1.date }
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return MindfulnessViewController.Section.allCases.count
    }

    func collectionView(
        _: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let sec = MindfulnessViewController.Section(rawValue: section)!

        switch sec {
        case .positiveMomentsHeader:
            return 1

        case .memories:
            return recentMemories.isEmpty ? 1 : recentMemories.count

        case .explore:
            return 3
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let sec = MindfulnessViewController.Section(rawValue: indexPath.section)!

        switch sec {
        case .positiveMomentsHeader:
            return configurePositiveMomentsCell(collectionView: collectionView, indexPath: indexPath)
        case .memories:
            return configureMemoriesCell(collectionView: collectionView, indexPath: indexPath)
        case .explore:
            return configureExploreCell(collectionView: collectionView, indexPath: indexPath)
        }
    }

    private func configurePositiveMomentsCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PositiveMomentsHeaderCell",
            for: indexPath
        ) as? PositiveMomentsHeaderCell else {
            fatalError("Expected PositiveMomentsHeaderCell for reuse identifier 'PositiveMomentsHeaderCell' at \(indexPath)")
        }
        cell.onManageTap = { [weak self] in
            let storyboard = UIStoryboard(name: "memory", bundle: nil)
            if let memoriesVC = storyboard.instantiateViewController(withIdentifier: "MemoriesViewController") as? MemoriesViewController {
                self?.viewController?.navigationController?.pushViewController(memoriesVC, animated: true)
            }
        }
        return cell
    }

    private func configureMemoriesCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        if recentMemories.isEmpty {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "MemoryEmptyStateCell",
                for: indexPath
            )
        }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HomeMemoryCell",
            for: indexPath
        ) as? HomeMemoryCell else {
            fatalError("Expected HomeMemoryCell for reuse identifier 'HomeMemoryCell' at \(indexPath)")
        }
        cell.configureWithMemory(recentMemories[indexPath.item])
        return cell
    }

    private func configureExploreCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "MindfulnessExploreLabelCell",
                for: indexPath
            )
        }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MindfulnessExploreCell",
            for: indexPath
        ) as? MindfulnessExploreCell else {
            fatalError("Expected MindfulnessExploreCell for reuse identifier 'MindfulnessExploreCell' at \(indexPath)")
        }

        if indexPath.item == 1 {
            cell.configure(
                title: "Breathing Sessions",
                subtitle: "Short guided sessions to help you relax and manage anxiety",
                icon: UIImage(named: "Breathing") ?? UIImage()
            )
            cell.didTap = { [weak self] in
                let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
                if let breathingVC = storyboard.instantiateViewController(withIdentifier: "BreathingViewController") as? BreathingViewController {
                    self?.viewController?.navigationController?.pushViewController(breathingVC, animated: true)
                }
            }
        } else {
            cell.configure(
                title: "Journaling",
                subtitle: "A space to write, reflect, and understand your day",
                icon: UIImage(named: "Journal") ?? UIImage()
            )
            cell.didTap = { [weak self] in
                let storyboard = UIStoryboard(name: "JournalMain", bundle: nil)
                if let journalVC = storyboard.instantiateViewController(withIdentifier: "JournalViewController") as? JournalViewController {
                    self?.viewController?.navigationController?.pushViewController(journalVC, animated: true)
                }
            }
        }
        return cell
    }
}
