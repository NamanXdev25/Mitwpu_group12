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
        title = "Exercise Plan"
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupData() {
        if exercisePlan == nil {
            exercisePlan = NewExercisePlan.level1Exercises
        }
        dataSource = NewExerciseDataSource(exercisePlan: exercisePlan)
        dataSource.delegate = self
    }

    private func setupCollectionView() {
        let headerNib = UINib(nibName: "NewExerciseHeaderCell", bundle: nil)
        collectionView.register(
            headerNib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "NewExerciseHeaderCell")

        let noteNib = UINib(nibName: "NewExerciseNoteCell", bundle: nil)
        collectionView.register(noteNib, forCellWithReuseIdentifier: "NewExerciseNoteCell")

        let exerciseNib = UINib(nibName: "DetailExerciseCell", bundle: nil)
        collectionView.register(exerciseNib, forCellWithReuseIdentifier: "DetailExerciseCell")

        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
    }

    private func setupBottomContainer() {
        bottomButtonContainer.layer.shadowColor = UIColor.black.cgColor
        bottomButtonContainer.layer.shadowOpacity = 0.1
        bottomButtonContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomButtonContainer.layer.shadowRadius = 4
    }

    // MARK: - IBActions
    @IBAction func beginButtonTapped(_ sender: UIButton) {
        guard let plan = exercisePlan, !plan.exercises.isEmpty else { return }

        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(
            withIdentifier: "ExercisePlayerViewController") as? ExercisePlayerViewController
        else {
            assertionFailure("ExercisePlayerViewController not found in NewExercise.storyboard")
            return
        }

        playerVC.exercisePlan  = plan
        playerVC.exerciseModel = plan.exercises[0]
        playerVC.currentIndex  = 0

        navigationController?.pushViewController(playerVC, animated: true)
    }

    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        print("Set as default tapped")
    }
}

// MARK: - DetailExerciseCellDelegate
extension NewExerciseViewController: DetailExerciseCellDelegate {
    func didTapChevron(on cell: DetailExerciseCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard indexPath.section == NewExerciseSectionType.exercises.rawValue else { return }

        let exercise = exercisePlan.exercises[indexPath.item]

        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(
            withIdentifier: "ExercisePlayerViewController") as? ExercisePlayerViewController
        else { return }

        playerVC.exercisePlan  = exercisePlan
        playerVC.exerciseModel = exercise
        playerVC.currentIndex  = indexPath.item

        navigationController?.pushViewController(playerVC, animated: true)
    }
}
