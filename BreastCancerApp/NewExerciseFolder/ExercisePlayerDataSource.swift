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
                description: descriptionFor(exercise)
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
        return Self.exerciseDescriptions[exercise.title]
            ?? "Follow the video and move at a comfortable pace."
    }

    // MARK: - Exercise Descriptions
    private static let exerciseDescriptions: [String: String] = [

        // Mobility / Early Recovery
        "Shoulder Shrug": "Lift both shoulders up toward your ears, then slowly lower them down to release tension and improve mobility.",
        "Shoulder Roll": "Roll your shoulders in a large circular motion to loosen the joints and reduce upper-body stiffness.",
        "Elbow Flex & Extend": "Slowly bend and straighten your elbow through its full range to restore mobility and ease joint stiffness.",
        "Wrist Circles": "Rotate your wrist in full circles, clockwise then counterclockwise, to mobilise the joint and ease surrounding tightness.",
        "Shoulder Blade Squeeze": "Draw both shoulder blades toward your spine and hold briefly to activate upper-back muscles and improve posture.",
        "Pendulum Arm Swing": "Let your arm hang freely and use gentle body movement to swing it in small circles, decompressing the shoulder joint.",
        "Wall Crawl (Front)": "Walk your fingers up a wall in front of you as high as comfortable to gradually increase shoulder flexion range.",
        "Wall Crawl (Side)": "Walk your fingers up a wall at your side at 90 degrees to build shoulder abduction mobility through a pain-free arc.",
        "Gentle Shoulder Abduction": "Slowly raise one arm out to the side to a comfortable height and lower it with control to ease shoulder stiffness.",
        "Chest Opening Stretch": "Lie on your back with arms out to the sides to open the chest and release tightness across the front of the shoulders.",
        "Neck Side Stretch": "Tilt your head toward one shoulder until you feel a gentle pull to relieve neck tension and improve cervical flexibility.",
        "Diaphragmatic Breathing": "Breathe deeply into your belly, letting your abdomen rise on the inhale, to strengthen the diaphragm and promote relaxation.",

        // Light Strength
        "Sit-to-Stand": "Lean forward from the edge of your chair and push through your feet to stand, building leg and hip strength for daily movement.",
        "Seated Knee Extension": "Slowly straighten one knee and squeeze the thigh at the top to strengthen the quadriceps and support knee stability.",
        "Standing Heel Raises": "Rise onto the balls of your feet and lower back down with control to strengthen the calves and improve ankle stability.",
        "Resistance Band Row": "Pull a resistance band toward you with elbows back and shoulder blades squeezed to build upper-back strength.",
        "Wall Push-Up": "Bend your elbows to bring your chest toward the wall and push back to strengthen the chest, shoulders, and arms.",
        "Bodyweight Mini Squat": "Bend your knees slightly as if sitting back into a chair, then return to standing, to build lower-body strength with low joint impact.",
        "Seated Core Bracing": "Gently draw your lower abdomen inward while seated to activate deep core stabilisers that protect your spine.",

        // Balance
        "Single Leg Stand": "Lift one foot slightly off the ground and hold to challenge your balance and strengthen ankle and hip stabilisers.",
        "Tandem Stand": "Place one foot directly in front of the other, heel to toe, to train postural control and reduce fall risk.",

        // Gentle Yoga
        "Seated Cat-Cow": "Alternate between arching and rounding your spine in a chair to mobilise the entire back and relieve tension."
    ]
    static func parseTargetDuration(_ duration: String) -> Double {
        let lower = duration.lowercased().trimmingCharacters(in: .whitespaces)
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
            return value * 60
        }
    }
}
