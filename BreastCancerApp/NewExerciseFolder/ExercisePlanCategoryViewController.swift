//
//  ExercisePlanCategoryViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 13/02/26.
//

import UIKit

class ExercisePlanCategoryViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    private var dataSource: ExercisePlanCategoryDataSource!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupDataSource()
        setupCollectionView()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Exercise Plans"
    }

    private func setupDataSource() {
        dataSource = ExercisePlanCategoryDataSource()
        dataSource.delegate = self
    }

    private func setupCollectionView() {
        let cellNib = UINib(nibName: "ExercisePlanCategoryCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "ExercisePlanCategoryCell")

        let headerNib = UINib(nibName: "ExercisePlanSectionHeader", bundle: nil)
        collectionView.register(
            headerNib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "ExercisePlanSectionHeader"
        )

        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.collectionViewLayout = makeCompositionalLayout()
    }

    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let cardWidth: CGFloat = 240
        let cardHeight: CGFloat = 232

        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self else { return nil }

            // Ask the data source directly — avoids raw value mismatch
            // when the recommended section is hidden
            let isRecommended = sectionIndex == 0
                && !ExerciseRecommendationEngine.recommendedCategories().isEmpty
            let itemCount = max(
                self.collectionView.numberOfItems(inSection: sectionIndex), 1
            )
            let isMulti = itemCount > 1

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(cardWidth),
                heightDimension: .absolute(cardHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupContentWidth = CGFloat(itemCount) * cardWidth + CGFloat(itemCount - 1) * 12
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(groupContentWidth),
                heightDimension: .absolute(cardHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(12)

            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.interGroupSpacing = 0

            // Recommended section gets extra bottom spacing to separate it from the rest
            let bottomInset: CGFloat = isRecommended ? 36 : 24
            layoutSection.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: 16, bottom: bottomInset, trailing: 16
            )

            if isMulti {
                layoutSection.orthogonalScrollingBehavior = .groupPaging
            }

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            layoutSection.boundarySupplementaryItems = [header]

            return layoutSection
        }
    }

    // MARK: - Navigation
    private func navigateToExerciseDetail(with category: ExercisePlanCategory) {
        let plan = convertCategoryToPlan(category)
        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "NewExerciseViewController") as? NewExerciseViewController {
            detailVC.exercisePlan = plan
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    private func convertCategoryToPlan(_ category: ExercisePlanCategory) -> NewExercisePlan {
        let exercises = category.exercises.map { exercise in
            NewExerciseModel(
                imageName: exercise.imageName,
                title: exercise.name,
                category: "Exercise",
                difficulty: "Medium",
                duration: exercise.details
            )
        }
        return NewExercisePlan(
            level: category.title,
            duration: extractDuration(from: category.subtitle),
            exerciseCount: category.exercises.count,
            note: "Important: \(category.importantNote)",
            exercises: exercises
        )
    }

    private func extractDuration(from subtitle: String) -> String {
        let components = subtitle.components(separatedBy: "·")
        if components.count >= 2 {
            return components[1].trimmingCharacters(in: .whitespaces)
        }
        return "20 min"
    }
}

// MARK: - ExercisePlanCategorySelectionDelegate
extension ExercisePlanCategoryViewController: ExercisePlanCategorySelectionDelegate {
    func didSelectCategory(_ category: ExercisePlanCategory) {
        navigateToExerciseDetail(with: category)
    }
}
