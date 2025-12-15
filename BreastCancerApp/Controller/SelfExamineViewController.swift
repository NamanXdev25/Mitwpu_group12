import UIKit

class SelfExamineViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Background with safe fallback
        let bg = UIColor(named: "BGPink") ??
                 UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1)
        view.backgroundColor = bg
        collectionView.backgroundColor = .clear

        // Delegates
        collectionView.delegate = self
        collectionView.dataSource = self

        // Register cells
        ["GuidesCardCell", "SectionTitleCell",
         "SelfExamCardsContainerCell", "ActionsContainerCell"].forEach {
            collectionView.register(UINib(nibName: $0, bundle: nil),
                                    forCellWithReuseIdentifier: $0)
        }

        // Layout (unchanged)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.setCollectionViewLayout(layout, animated: false)

        // Navigation bar appearance
        let navBar = navigationController?.navigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bg
        appearance.shadowColor = .clear

        navBar?.standardAppearance = appearance
        navBar?.scrollEdgeAppearance = appearance
        navBar?.compactAppearance = appearance
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isTranslucent = false

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Self-Exam"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segues preserved exactly.
    }
}


// MARK: - UICollectionViewDataSource
extension SelfExamineViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { 4 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let id: String = [
            "GuidesCardCell",
            "SectionTitleCell",
            "SelfExamCardsContainerCell",
            "ActionsContainerCell"
        ][indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        switch (indexPath.item, cell) {

        case (0, let c as GuidesCardCell):
            c.titleLabel.text = "Guides"
            c.row1Label.text = "Video Guide"
            c.row2Label.text = "Audio Guide"
            c.delegate = self

        case (1, let c as SectionTitleCell):
            c.titleLabel.text = "How to Self-Examine?"

        case (3, let c as ActionsContainerCell):
            c.delegate = self

        default: break
        }

        return cell
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension SelfExamineViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width - 32

        switch indexPath.item {
        case 0: return .init(width: width, height: 180)
        case 1: return .init(width: width, height: 44)
        case 2: return .init(width: width, height: 200)
        case 3: return .init(width: width, height: 140)
        default: return .init(width: width, height: 60)
        }
    }
}


// MARK: - GuidesCardCellDelegate
extension SelfExamineViewController: GuidesCardCellDelegate {

    func guidesCellDidTapVideo(_ cell: GuidesCardCell) {
        performSegue(withIdentifier: "ShowVideoGuide", sender: cell)
    }

    func guidesCellDidTapAudio(_ cell: GuidesCardCell) {
        performSegue(withIdentifier: "ShowAudioGuide", sender: cell)
    }
}


// MARK: - ActionsContainerCellDelegate
extension SelfExamineViewController: ActionsContainerCellDelegate {

    func didTapLogSelfExam(from cell: ActionsContainerCell) {
        performSegue(withIdentifier: "showObservations", sender: cell)
    }

    func didTapViewPastTests(from cell: ActionsContainerCell) {
        performSegue(withIdentifier: "showTestHistory", sender: cell)
    }
}
