//
//  NewExerciseViewController.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 05/02/26.
//

import UIKit

class NewExerciseViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    //@IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var bottomButtonContainer: UIView!
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var defaultButton: UIButton!
    
    // MARK: - Properties
    var exercisePlan: NewExercisePlan!
    private var dataSource: NewExerciseDataSource!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupData()
        setupCollectionView()
        setupBottomContainer()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        // If you want to show "Exercise Plan" title
        title = "Exercise Plan"
        
        // Or hide navigation bar if using custom back button
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupData() {
        // Set default to Level 1, can be changed based on navigation
        if exercisePlan == nil {
            exercisePlan = NewExercisePlan.level1Exercises
        }
        dataSource = NewExerciseDataSource(exercisePlan: exercisePlan)
        dataSource.delegate = self
    }
    
    private func setupCollectionView() {
        // Register header
        let headerNib = UINib(nibName: "NewExerciseHeaderCell", bundle: nil)
        collectionView.register(
            headerNib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "NewExerciseHeaderCell"
        )
        
        // Register note cell
        let noteNib = UINib(nibName: "NewExerciseNoteCell", bundle: nil)
        collectionView.register(noteNib, forCellWithReuseIdentifier: "NewExerciseNoteCell")
        
        // Register exercise cell
        let exerciseNib = UINib(nibName: "DetailExerciseCell", bundle: nil)
        collectionView.register(exerciseNib, forCellWithReuseIdentifier: "DetailExerciseCell")
        
        // Set datasource and delegate
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        // Collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
    }
    
    private func setupBottomContainer() {
        // Add shadow to bottom container
        bottomButtonContainer.layer.shadowColor = UIColor.black.cgColor
        bottomButtonContainer.layer.shadowOpacity = 0.1
        bottomButtonContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomButtonContainer.layer.shadowRadius = 4
    }
    
    // MARK: - IBActions
//    @IBAction func backButtonTapped(_ sender: UIButton) {
//        // If in navigation controller
//        if navigationController != nil {
//            navigationController?.popViewController(animated: true)
//        } else {
//            // If presented modally
//            dismiss(animated: true)
//        }
//    }
    
    @IBAction func beginButtonTapped(_ sender: UIButton) {
        // Handle begin exercise flow
        print("Begin exercise tapped")
    }
    
    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        // Handle set as default
        print("Set as default tapped")
    }
}

// MARK: - DetailExerciseCellDelegate
extension NewExerciseViewController: DetailExerciseCellDelegate {
    func didTapChevron(on cell: DetailExerciseCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        // Adjust for sections (exercises are in section 2)
        if indexPath.section == NewExerciseSectionType.exercises.rawValue {
            let exercise = exercisePlan.exercises[indexPath.item]
            
            // Navigate to exercise detail screen
            print("Chevron tapped for: \(exercise.title)")
            // TODO: Navigate to detail screen
        }
    }
}
