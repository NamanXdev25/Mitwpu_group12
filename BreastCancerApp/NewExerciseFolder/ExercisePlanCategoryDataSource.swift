//
//  ExercisePlanCategoryDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/02/26.
//

import UIKit

enum ExercisePlanSection: Int, CaseIterable {
    case postSurgery = 0
    case postRecovery = 1
    case chemotherapy = 2
    case radiation = 3
    case reconstruction = 4
    case recovery = 5
    
    var title: String {
        switch self {
        case .postSurgery:
            return "Post-Surgery Exercises"
        case .postRecovery:
            return "Post-Recovery Exercises"
        case .chemotherapy:
            return "Chemotherapy Exercises"
        case .radiation:
            return "Radiation Therapy Exercises"
        case .reconstruction:
            return "Breast Reconstruction Exercises"
        case .recovery:
            return "Recovery & Survivorship"
        }
    }
    
    var categories: [ExercisePlanCategory] {
        switch self {
        case .postSurgery:
            return ExercisePlanCategory.postSurgeryCategories
        case .postRecovery:
            return ExercisePlanCategory.postRecoveryCategories
        case .chemotherapy:
            return ExercisePlanCategory.chemotherapyCategories
        case .radiation:
            return ExercisePlanCategory.radiationCategories
        case .reconstruction:
            return ExercisePlanCategory.reconstructionCategories
        case .recovery:
            return ExercisePlanCategory.recoveryCategories
        }
    }
}

protocol ExercisePlanCategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: ExercisePlanCategory)
}

class ExercisePlanCategoryDataSource: NSObject {
    
    weak var delegate: ExercisePlanCategorySelectionDelegate?
    
    private let sections = ExercisePlanSection.allCases
}

// MARK: - UICollectionViewDataSource
extension ExercisePlanCategoryDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ExercisePlanCategoryCell",
            for: indexPath
        ) as? ExercisePlanCategoryCell else {
            return UICollectionViewCell()
        }
        
        let section = sections[indexPath.section]
        let category = section.categories[indexPath.item]
        cell.configure(with: category)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ExercisePlanSectionHeader",
                for: indexPath
            ) as? ExercisePlanSectionHeader else {
                return UICollectionReusableView()
            }
            
            let section = sections[indexPath.section]
            headerView.configure(with: section.title)
            return headerView
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate
extension ExercisePlanCategoryDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let category = section.categories[indexPath.item]
        delegate?.didSelectCategory(category)
    }
}

//// MARK: - UICollectionViewDelegateFlowLayout
//extension ExercisePlanCategoryDataSource: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 50)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width
//        let section = sections[indexPath.section]
//        let category = section.categories[indexPath.item]
//        let itemWidth = (width - 48) / 2
//
//        // Measure how tall the subtitle will be
//        let subtitleFont = UIFont.preferredFont(forTextStyle: .subheadline)
//        let labelWidth = itemWidth - 32 // 16pt padding each side
//        let boundingSize = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
//        let subtitleHeight = (category.subtitle as NSString).boundingRect(
//            with: boundingSize,
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            attributes: [.font: subtitleFont],
//            context: nil
//        ).height
//
//        // 100 image + 12 gap + 20 title + 4 spacing + subtitle + 16 bottom padding
//        let totalHeight = 100 + 12 + 20 + 4 + ceil(subtitleHeight) + 16
//        return CGSize(width: itemWidth, height: max(totalHeight, 180))
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 16
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 16
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
//    }
//}
