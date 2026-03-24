import UIKit

class NewExerciseViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButtonContainer: UIView!
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var defaultButton: UIButton!

    // MARK: - Properties
    var exercisePlan: NewExercisePlan!
    var exerciseCategoryID: Int?
    var onPlanStateChanged: ((Bool) -> Void)?
    private var dataSource: NewExerciseDataSource!

    private var completedIndices: Set<Int> = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupData()
        setupCollectionView()
        setupBottomContainer()
        updateBeginButtonTitle()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = nil
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func setupData() {
        if exercisePlan == nil {
        }
        loadCompletedIndices()
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

    // MARK: - Begin / Continue Button

    private func updateBeginButtonTitle() {
        let hasAnyCompleted = !completedIndices.isEmpty
        beginButton.configuration?.title = hasAnyCompleted ? " Continue" : " Begin Now"
    }

    private func nextExerciseIndex() -> Int {
        guard let plan = exercisePlan else { return 0 }
        for i in 0..<plan.exercises.count {
            if !completedIndices.contains(i) {
                return i
            }
        }
        return 0
    }

    // MARK: - Player Navigation

    private func openExercisePlayer(for exercise: NewExerciseModel, at index: Int) {
        let storyboard = UIStoryboard(name: "NewExercise", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(
            withIdentifier: "ExercisePlayerViewController"
        ) as? ExercisePlayerViewController else { return }

        playerVC.exerciseModel = exercise
        playerVC.exercisePlan  = exercisePlan
        playerVC.currentIndex  = index
        playerVC.onExerciseMarkedDone = { [weak self] completedIndex in
            self?.markExerciseAsDone(at: completedIndex)
        }
        navigationController?.pushViewController(playerVC, animated: true)
    }

    private func markExerciseAsDone(at index: Int) {
        guard !completedIndices.contains(index) else { return }
        completedIndices.insert(index)
        setExerciseCompletion(for: index, completed: true)
        updateBeginButtonTitle()
        reloadExerciseCell(at: index)
        onPlanStateChanged?(!completedIndices.isEmpty)
    }

    private func reloadExerciseCell(at exerciseIndex: Int) {
        let indexPath = IndexPath(
            item: exerciseIndex,
            section: NewExerciseSectionType.exercises.rawValue
        )
        collectionView.reloadItems(at: [indexPath])
    }

    // MARK: - Completion State Query (used by DataSource)

    func isExerciseCompleted(at index: Int) -> Bool {
        return completedIndices.contains(index)
    }

    private func loadCompletedIndices() {
        guard let plan = exercisePlan else {
            completedIndices = []
            return
        }

        let completedIDs = UserActivityStore.shared.completedExerciseIDs(on: Date())
        completedIndices = Set(
            plan.exercises.enumerated().compactMap { index, exercise in
                completedIDs.contains(exerciseIdentifier(for: exercise)) ? index : nil
            }
        )
    }

    private func setExerciseCompletion(for index: Int, completed: Bool) {
        guard let plan = exercisePlan, index < plan.exercises.count else { return }
        let exercise = plan.exercises[index]
        UserActivityStore.shared.setExerciseCompleted(
            completed,
            exerciseID: exerciseIdentifier(for: exercise),
            title: exercise.title,
            duration: exercise.duration,
            planId: exerciseCategoryID
        )
    }

    private func exerciseIdentifier(for exercise: NewExerciseModel) -> String {
        let parts = [
            exercisePlan?.level ?? "exercise",
            exercise.title,
            exercise.category,
            exercise.duration
        ]
        return parts.joined(separator: "|")
    }

    // MARK: - IBActions

    @IBAction func beginButtonTapped(_ sender: UIButton) {
        guard let plan = exercisePlan, !plan.exercises.isEmpty else { return }

        let index = nextExerciseIndex()
        let exercise = plan.exercises[index]
        openExercisePlayer(for: exercise, at: index)
    }

    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        guard let categoryID = exerciseCategoryID, categoryID > 0 else { return }

        let exerciseRepo: ExerciseRepository = RepositoryFactory.makeExerciseRepository()
        exerciseRepo.saveSelectedPlanID(categoryID)

        NotificationCenter.default.post(
            name: NSNotification.Name("ExerciseDefaultPlanChanged"),
            object: nil
        )

        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        toastLabel.text = "Plan added"
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 18
        toastLabel.clipsToBounds = true
        
        let maxWidth = view.frame.width - 60
        let expectedSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        let width = min(expectedSize.width + 48, maxWidth)
        let height = max(expectedSize.height + 16, 36)
        
        toastLabel.frame = CGRect(
            x: view.frame.width / 2 - width / 2,
            y: view.frame.height - bottomButtonContainer.frame.height - 40 - height,
            width: width,
            height: height
        )
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}

// MARK: - DetailExerciseCellDelegate
extension NewExerciseViewController: DetailExerciseCellDelegate {

    func didTapChevron(on cell: DetailExerciseCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard indexPath.section == NewExerciseSectionType.exercises.rawValue else { return }

        let exercise = exercisePlan.exercises[indexPath.item]
        openExercisePlayer(for: exercise, at: indexPath.item)
    }

    func didTapRadioButton(on cell: DetailExerciseCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard indexPath.section == NewExerciseSectionType.exercises.rawValue else { return }

        let index = indexPath.item
        if completedIndices.contains(index) {
            completedIndices.remove(index)
        } else {
            completedIndices.insert(index)
        }

        setExerciseCompletion(for: index, completed: completedIndices.contains(index))
        updateBeginButtonTitle()
        reloadExerciseCell(at: index)
        onPlanStateChanged?(!completedIndices.isEmpty)
    }
}
