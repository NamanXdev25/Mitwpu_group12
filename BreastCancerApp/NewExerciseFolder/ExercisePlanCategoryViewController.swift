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
        // Register cell
        let cellNib = UINib(nibName: "ExercisePlanCategoryCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "ExercisePlanCategoryCell")
        
        // Register header
        let headerNib = UINib(nibName: "ExercisePlanSectionHeader", bundle: nil)
        collectionView.register(
            headerNib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "ExercisePlanSectionHeader"
        )
        
        // Set datasource and delegate
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - Navigation
    private func navigateToExerciseDetail(with category: ExercisePlanCategory) {
        // If category has a related plan (Level 1 or Level 2)
        if let relatedPlan = category.relatedPlan {
            let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "NewExerciseViewController") as? NewExerciseViewController {
                detailVC.exercisePlan = relatedPlan
                navigationController?.pushViewController(detailVC, animated: true)
            }
        } else {
            // For other categories, convert to NewExercisePlan format
            let tempPlan = convertCategoryToPlan(category)
            
            let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "NewExerciseViewController") as? NewExerciseViewController {
                detailVC.exercisePlan = tempPlan
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    private func convertCategoryToPlan(_ category: ExercisePlanCategory) -> NewExercisePlan {
        // Convert CategoryExercise to NewExerciseModel
        let exercises = category.exercises.map { exercise -> NewExerciseModel in
            return NewExerciseModel(
                imageName: "", // Empty for now, will add images later
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
        // Extract duration from subtitle
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
