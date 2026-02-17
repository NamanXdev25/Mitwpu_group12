//import UIKit
//
//class MindfulnessDataSource: NSObject, UICollectionViewDataSource {
//
//    weak var viewController: MindfulnessViewController?
//
//    init(viewController: MindfulnessViewController) {
//        self.viewController = viewController
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return MindfulnessViewController.Section.allCases.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int
//    ) -> Int {
//
//        let sec = MindfulnessViewController.Section(rawValue: section)!
//
//        switch sec {
//        case .positiveMomentsHeader:
//            return 1
//
//        case .memories:
//            return 3
//
//        case .explore:
//            return 3
//        }
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//
//        let sec = MindfulnessViewController.Section(rawValue: indexPath.section)!
//
//        switch sec {
//
//        // MARK: - HEADER
//        case .positiveMomentsHeader:
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "PositiveMomentsHeaderCell",
//                for: indexPath
//            ) as! PositiveMomentsHeaderCell
//
//            cell.onManageTap = {
//                print("View All tapped")
//            }
//
//            return cell
//
//        // MARK: - MEMORY IMAGES (UNCHANGED)
//        case .memories:
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "HomeMemoryCell",
//                for: indexPath
//            ) as! HomeMemoryCell
//
//            let models: [HomeMemoryModel] = [
//                HomeMemoryModel(
//                    imageName: "memory_1",
//                    date: "Apr 14",
//                    description: "Beautiful day at the park. Feeling grateful."
//                ),
//                HomeMemoryModel(
//                    imageName: "memory_2",
//                    date: "Apr 10",
//                    description: "Quality time with loved ones. These moments matter."
//                ),
//                HomeMemoryModel(
//                    imageName: "memory_3",
//                    date: "Apr 05",
//                    description: "A calm evening walk to clear my mind."
//                )
//            ]
//
//            cell.configure(with: models[indexPath.item])
//            return cell
//
//        // MARK: - EXPLORE
//        case .explore:
//            if indexPath.item == 0 {
//                return collectionView.dequeueReusableCell(
//                    withReuseIdentifier: "MindfulnessExploreLabelCell",
//                    for: indexPath
//                )
//            }
//
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "MindfulnessExploreCell",
//                for: indexPath
//            ) as! MindfulnessExploreCell
//
//            if indexPath.item == 1 {
//                cell.configure(
//                    title: "Breathing Sessions",
//                    subtitle: "Short guided sessions to help you relax and manage anxiety",
//                    icon: UIImage(named: "Breathing")!
//                )
//            } else {
//                cell.configure(
//                    title: "Journaling",
//                    subtitle: "A space to write, reflect, and understand your day",
//                    icon: UIImage(named: "Journal")!
//                )
//            }
//
//            return cell
//        }
//    }
//}


import UIKit

class MindfulnessDataSource: NSObject, UICollectionViewDataSource {

    weak var viewController: MindfulnessViewController?

    init(viewController: MindfulnessViewController) {
        self.viewController = viewController
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
            return 3

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

        // MARK: - HEADER
        case .positiveMomentsHeader:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PositiveMomentsHeaderCell",
                for: indexPath
            ) as! PositiveMomentsHeaderCell

            cell.onManageTap = {
                print("View All tapped")
            }

            return cell

        // MARK: - MEMORY IMAGES (UNCHANGED)
        case .memories:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HomeMemoryCell",
                for: indexPath
            ) as! HomeMemoryCell

            let models: [HomeMemoryModel] = [
                HomeMemoryModel(
                    imageName: "memory_1",
                    date: "Apr 14",
                    description: "Beautiful day at the park. Feeling grateful."
                ),
                HomeMemoryModel(
                    imageName: "memory_2",
                    date: "Apr 10",
                    description: "Quality time with loved ones. These moments matter."
                ),
                HomeMemoryModel(
                    imageName: "memory_3",
                    date: "Apr 05",
                    description: "A calm evening walk to clear my mind."
                )
            ]

            cell.configure(with: models[indexPath.item])
            return cell

        // MARK: - EXPLORE
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
                // Breathing Sessions
                cell.configure(
                    title: "Breathing Sessions",
                    subtitle: "Short guided sessions to help you relax and manage anxiety",
                    icon: UIImage(named: "Breathing")!
                )
                
                // Navigate to BreathingViewController via push
                cell.didTap = { [weak self] in
                    let storyboard = UIStoryboard(name: "BreathingSessions", bundle: nil)
                    if let breathingVC = storyboard.instantiateViewController(withIdentifier: "BreathingViewController") as? BreathingViewController {
                        self?.viewController?.navigationController?.pushViewController(breathingVC, animated: true)
                    }
                }
                
            } else {
                // Journaling
                cell.configure(
                    title: "Journaling",
                    subtitle: "A space to write, reflect, and understand your day",
                    icon: UIImage(named: "Journal")!
                )
                
                // Add journaling navigation if needed
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
