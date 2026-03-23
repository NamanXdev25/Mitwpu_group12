import UIKit

protocol ExercisePlayerDataSourceDelegate: AnyObject {
    func didConfigureVideoCell(_ cell: VideoPlayerCell)
    func didUpdateTotalDuration(_ seconds: Double)
    func didTapInfo(from button: UIButton)
    func didTogglePlayPause()
    func didRestart()
    func didToggleLoop(enabled: Bool)
    func didSeek(toProgress progress: Float)
    func didTapMarkAsDone()
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
                guard let self else { return }
                self.totalDuration = seconds
                self.delegate?.didUpdateTotalDuration(seconds)
            }

            // ⚠️ Must set targetDuration BEFORE configure() — configure() snapshots it immediately
            cell.targetDuration = Self.parseTargetDuration(exercise.duration)

            let videoName = exercise.title.replacingOccurrences(of: " ", with: "_")
            cell.configure(videoName: videoName, imageName: exercise.imageName)
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
            cell.setDone(false)

            cell.onMarkAsDone = { [weak self] in self?.delegate?.didTapMarkAsDone() }
            cell.onNext       = { [weak self] in self?.delegate?.didTapNext() }

            return cell

        default:
            return UICollectionViewCell()
        }
    }

    // MARK: - Helpers

    private func descriptionFor(_ exercise: NewExerciseModel) -> String {
        return "Duration: \(exercise.duration). Follow the video and move at a comfortable pace."
    }

    /// Parses "4 min", "2.5 min", "30 sec" → seconds as Double. Returns 0 if unparseable.
    static func parseTargetDuration(_ duration: String) -> Double {
        let lower = duration.lowercased().trimmingCharacters(in: .whitespaces)

        // Extract numeric portion (digits + decimal point only)
        var numericString = ""
        for ch in lower {
            if ch.isNumber || ch == "." {
                numericString.append(ch)
            }
        }

        guard let value = Double(numericString), value > 0 else { return 0 }

        if lower.contains("sec") {
            return value
        } else {
            // Default to minutes → convert to seconds
            return value * 60
        }
    }
}
