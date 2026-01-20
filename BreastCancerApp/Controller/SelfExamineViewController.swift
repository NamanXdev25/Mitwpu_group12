import UIKit

class SelfExamineViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        [
            "GuidesCardCell",
            "SectionTitleCell",
            "SelfExamCardsContainerCell",
            "ActionsContainerCell"
        ].forEach {
            collectionView.register(
                UINib(nibName: $0, bundle: nil),
                forCellWithReuseIdentifier: $0
            )
        }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )

        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segues preserved exactly.
    }
}


// MARK: - UICollectionViewDataSource
extension SelfExamineViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 4
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        // UPDATED ORDER
        let id: String = [
            "SectionTitleCell",              // How to Self-Examine
            "SelfExamCardsContainerCell",    // Horizontal cards
            "GuidesCardCell",                // Video + Audio guides
            "ActionsContainerCell"           // Bottom buttons
        ][indexPath.item]

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: id,
            for: indexPath
        )

        switch (indexPath.item, cell) {

        case (2, let c as GuidesCardCell):
            c.delegate = self

        case (3, let c as ActionsContainerCell):
            c.delegate = self

        default:
            break
        }

        return cell
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension SelfExamineViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.frame.width - 32

        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: 44)    // Section title
        case 1:
            return CGSize(width: width, height: 200)   // Horizontal cards
        case 2:
            return CGSize(width: width, height: 180)   // Guides
        case 3:
            return CGSize(width: width, height: 140)   // Actions
        default:
            return CGSize(width: width, height: 60)
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
