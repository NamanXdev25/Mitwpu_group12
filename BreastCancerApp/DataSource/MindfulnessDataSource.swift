//
//  MindfulnessDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 10/12/25.
//

import UIKit

class MindfulnessDataSource: NSObject, UICollectionViewDataSource {

    weak var viewController: MindfulnessViewController?
    


    init(viewController: MindfulnessViewController) {
        self.viewController = viewController
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MindfulnessViewController.Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        guard let vc = viewController else { return 0 }
        let sec = MindfulnessViewController.Section(rawValue: section)!

        switch sec {
        case .emotions:
            return vc.selectedEmotionIndex == nil ? 1 : 0

        case .slideCard:
            return vc.selectedEmotionIndex == nil ? 0 : 1

        case .explore:
            return 3
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {

        guard let vc = viewController else {
            fatalError("Missing VC")
        }

        let sec = MindfulnessViewController.Section(rawValue: indexPath.section)!

        switch sec {

        case .emotions:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "EmotionPickerCell",
                for: indexPath
            ) as! EmotionPickerCell

            cell.didSelectEmotion = { index in
                vc.handleEmotionTap(index)
            }
            return cell

        case .slideCard:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SlideCardCell",
                for: indexPath
            ) as! SlideCardCell

            cell.configure(initialSlidesCount: vc.slides.count)
            return cell

        case .explore:
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ExploreLabelCell",
                    for: indexPath
                ) as! ExploreLabelCell
                cell.titleLabel.text = "Explore"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ExploreCell",
                    for: indexPath
                ) as! ExploreCell

                if indexPath.item == 1 {
                    cell.configure(
                        title: "Breathing Sessions",
                        subtitle: "Short guided sessions to help you relax and manage anxiety",
                        icon: UIImage(named: "Breathing")!
                    )

                } else {
                    cell.configure(
                        title: "Journaling",
                        subtitle: "A space to write, reflect, and understand your day",
                        icon: UIImage(named: "Journal")!
                    )
                }

                return cell
            }
        }
    }
}
