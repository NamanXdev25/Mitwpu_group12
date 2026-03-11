import UIKit

class MindfulnessDataSource: NSObject, UICollectionViewDataSource {

    weak var viewController: MindfulnessViewController?
    private(set) var memories: [Memory] = []

    init(viewController: MindfulnessViewController) {
        self.viewController = viewController
        super.init()
        reloadMemories()
    }

    func reloadMemories() {
        memories = MemoryStore.load().sorted { $0.date > $1.date }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MindfulnessViewController.Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let sec = MindfulnessViewController.Section(rawValue: section)!

        switch sec {
        case .positiveMomentsHeader:
            return 1

        case .memories:
            return memories.isEmpty ? 1 : memories.count

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
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PositiveMomentsHeaderCell",
                for: indexPath
            ) as! PositiveMomentsHeaderCell

            cell.onManageTap = { [weak self] in
                let storyboard = UIStoryboard(name: "memory", bundle: nil)
                if let memoriesVC = storyboard.instantiateViewController(withIdentifier: "MemoriesViewController") as? MemoriesViewController {
                    self?.viewController?.navigationController?.pushViewController(memoriesVC, animated: true)
                }
            }

            return cell

        case .memories:
            if memories.isEmpty {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MemoryEmptyStateCell",
                    for: indexPath
                )
            }

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HomeMemoryCell",
                for: indexPath
            ) as! HomeMemoryCell

            cell.configureWithMemory(memories[indexPath.item])
            return cell

        case .explore:
            if indexPath.item == 0 {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MindfulnessExploreLabelCell",
                    for: indexPath
                )
            }

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MindfulnessExploreCell",
                for: indexPath
            ) as! MindfulnessExploreCell

            if indexPath.item == 1 {
                cell.configure(
                    title: "Breathing Sessions",
                    subtitle: "Short guided sessions to help you relax and manage anxiety",
                    icon: UIImage(named: "Breathing")!
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
                    icon: UIImage(named: "Journal")!
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
}
