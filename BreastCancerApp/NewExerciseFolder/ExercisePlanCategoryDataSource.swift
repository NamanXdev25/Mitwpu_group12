
import UIKit

enum ExercisePlanSection: Int, CaseIterable {
    case recommended = 0
    case postSurgery = 1
    case postRecovery = 2
    case chemotherapy = 3
    case radiation = 4
    case reconstruction = 5
    case recovery = 6
    
    var title: String {
        switch self {
        case .recommended:
            return "Recommended for You"
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
        case .recommended:
            return ExerciseRecommendationEngine.recommendedCategories()
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
    
    private var sections: [ExercisePlanSection] {
        ExercisePlanSection.allCases.filter { section in
            if section == .recommended {
                return !ExerciseRecommendationEngine.recommendedCategories().isEmpty
            }
            return true
        }
    }
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

