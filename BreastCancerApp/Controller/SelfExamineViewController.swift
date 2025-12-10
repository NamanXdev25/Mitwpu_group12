import UIKit

class SelfExamineViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // SAFE BACKGROUND COLOR (fallback if asset missing)
        let bg = UIColor(named: "BGPink") ??
                 UIColor(red: 0.98, green: 0.95, blue: 0.96, alpha: 1)

        view.backgroundColor = bg
        collectionView.backgroundColor = .clear

        collectionView.delegate = self
        collectionView.dataSource = self

        // Register cells
        collectionView.register(UINib(nibName: "GuidesCardCell", bundle: nil),
                                forCellWithReuseIdentifier: "GuidesCardCell")
        collectionView.register(UINib(nibName: "SectionTitleCell", bundle: nil),
                                forCellWithReuseIdentifier: "SectionTitleCell")
        collectionView.register(UINib(nibName: "SelfExamCardsContainerCell", bundle: nil),
                                forCellWithReuseIdentifier: "SelfExamCardsContainerCell")
        collectionView.register(UINib(nibName: "ActionsContainerCell", bundle: nil),
                                forCellWithReuseIdentifier: "ActionsContainerCell")

        // CollectionView Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.setCollectionViewLayout(layout, animated: false)

        // NavigationBar title
        navigationController?.navigationBar.prefersLargeTitles = false
        let titleLabel = UILabel()
        titleLabel.text = "Self-Exam"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel

        // REMOVE NAVIGATION BAR HAIRLINE COMPLETELY
        let nav = navigationController?.navigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bg

        // remove shadow / line and images
        appearance.shadowColor = .clear
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()

        nav?.standardAppearance = appearance
        nav?.scrollEdgeAppearance = appearance
        nav?.compactAppearance = appearance

        // additional removal for all iOS versions
        nav?.setBackgroundImage(UIImage(), for: .default)
        nav?.shadowImage = UIImage()
        nav?.isTranslucent = false

        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showObservations" {
            // pass if needed
        } else if segue.identifier == "showTestHistory" {
            // pass if needed
        } else if segue.identifier == "ShowVideoGuide" {
            // pass if needed
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SelfExamineViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 4  // Guides + Title + Horizontal Cards + Actions
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "GuidesCardCell",
                for: indexPath
            ) as! GuidesCardCell

            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            cell.titleLabel.text = "Guides"
            cell.row1Label.text = "Video Guide"
            cell.row2Label.text = "Audio Guide"
            cell.delegate = self // assign delegate for per-row taps
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SectionTitleCell",
                for: indexPath
            ) as! SectionTitleCell

            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.titleLabel.text = "How to Self-Examine?"
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "SelfExamCardsContainerCell",
                for: indexPath
            ) as! SelfExamCardsContainerCell

            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ActionsContainerCell",
                for: indexPath
            ) as! ActionsContainerCell

            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.delegate = self
            return cell

        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelfExamineViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let fullWidth = collectionView.frame.width - 32

        switch indexPath.item {
        case 0: return CGSize(width: fullWidth, height: 180)
        case 1: return CGSize(width: fullWidth, height: 44)
        case 2: return CGSize(width: fullWidth, height: 200)
        case 3: return CGSize(width: fullWidth, height: 140)
        default: return CGSize(width: fullWidth, height: 60)
        }
    }
}

// NOTE: whole-card tap removed to avoid accidental navigation

// MARK: - GuidesCardCellDelegate
extension SelfExamineViewController: GuidesCardCellDelegate {
    func guidesCellDidTapVideo(_ cell: GuidesCardCell) {
        performSegue(withIdentifier: "ShowVideoGuide", sender: cell)
    }

    func guidesCellDidTapAudio(_ cell: GuidesCardCell) {
        // currently no-op; implement audio screen later
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
