//
//  ExercisePlayerDataSource.swift
//  BreastCancerApp
//
//  Created by Shivani Dinesh on 19/02/26.
//

import UIKit

protocol ExercisePlayerDataSourceDelegate: AnyObject {
    /// Called when the video cell is ready so the VC can keep a weak ref
    func didConfigureVideoCell(_ cell: VideoPlayerCell)
    /// Called when AVPlayer reports the real video duration
    func didUpdateTotalDuration(_ seconds: Double)
    /// Called when the info (i) button is tapped
    func didTapInfo(from button: UIButton)
    /// Called when play/pause is toggled
    func didTogglePlayPause()
    /// Called when restart is tapped
    func didRestart()
    /// Called when loop is toggled
    func didToggleLoop(enabled: Bool)
    /// Called when slider seek ends
    func didSeek(toProgress progress: Float)
    /// Called when "Mark as Done" is tapped
    func didTapMarkAsDone()
    /// Called when "Next" is tapped
    func didTapNext()
}

// MARK: - ExercisePlayerDataSource
class ExercisePlayerDataSource: NSObject {

    // MARK: - Properties
    let exercise: NewExerciseModel
    let exercisePlan: NewExercisePlan
    let currentIndex: Int
    var totalDuration: Double = 1.0

    weak var delegate: ExercisePlayerDataSourceDelegate?

    // MARK: - Init
    init(exercise: NewExerciseModel, plan: NewExercisePlan, index: Int) {
        self.exercise = exercise
        self.exercisePlan = plan
        self.currentIndex = index
    }

    var isLastExercise: Bool {
        return currentIndex >= exercisePlan.exercises.count - 1
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ExercisePlayerDataSource: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {

        // MARK: Section 0 — Video Player
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerCell

            cell.onDurationChanged = { [weak self] seconds in
                guard let self = self else { return }
                self.totalDuration = seconds
                self.delegate?.didUpdateTotalDuration(seconds)
            }

            // Video file name convention: match the imageName (same asset name, different extension)
            cell.configure(videoName: exercise.imageName, imageName: exercise.imageName)
            delegate?.didConfigureVideoCell(cell)

            return cell

        // MARK: Section 1 — Exercise Info
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ExerciseInfoCell", for: indexPath) as! ExerciseInfoCell

            cell.configure(
                title: exercise.title,
                description: descriptionFor(exercise),
                level: exercise.difficulty
            )

            cell.onInfoTap = { [weak self] button in
                self?.delegate?.didTapInfo(from: button)
            }

            return cell

        // MARK: Section 2 — Video Controls
        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "VideoControlsCell", for: indexPath) as! VideoControlsCell

            cell.configure(currentTime: 0, totalTime: Int(totalDuration))

            cell.onPlayPause = { [weak self] in self?.delegate?.didTogglePlayPause() }
            cell.onRestart   = { [weak self] in self?.delegate?.didRestart() }
            cell.onLoop      = { [weak self] looping in self?.delegate?.didToggleLoop(enabled: looping) }
            cell.onSeek      = { [weak self] progress in self?.delegate?.didSeek(toProgress: progress) }

            return cell

        // MARK: Section 3 — Action Buttons
        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ActionButtonsCell", for: indexPath) as! ActionButtonsCell

            cell.setIsLastExercise(isLastExercise)
            cell.setDone(false) // default; VC can update after

            cell.onMarkAsDone = { [weak self] in self?.delegate?.didTapMarkAsDone() }
            cell.onNext       = { [weak self] in self?.delegate?.didTapNext() }

            return cell

        default:
            return UICollectionViewCell()
        }
    }

    // MARK: - Helper
    private func descriptionFor(_ exercise: NewExerciseModel) -> String {
        // Derive a sensible description from the model data.
        // You can later extend NewExerciseModel with a `description` property
        // and remove this helper entirely.
        return "A \(exercise.difficulty.lowercased())-difficulty \(exercise.category.lowercased()) exercise. Duration: \(exercise.duration)."
    }
}
